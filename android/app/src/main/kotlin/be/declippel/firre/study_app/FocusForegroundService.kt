package be.declippel.firre.study_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import java.util.HashSet

/**
 * Keeps a persistent notification while a focus session is active and now
 * also owns app blocking: every second it reads the foreground app from
 * UsageStatsManager (needs the "Usage access" special permission) and, when
 * a non-whitelisted app is in front, draws a full-screen
 * TYPE_APPLICATION_OVERLAY window on top of it. No AccessibilityService is
 * required for blocking.
 */
class FocusForegroundService : Service() {

    companion object {
        private const val TAG = "FocusFlowBlocker"
        private const val CHANNEL_ID = "focusflow_session"
        private const val NOTIFICATION_ID = 1001
        private const val ACTION_SESSION_ENDED = "focusflow.SESSION_ENDED"
        // How far back to look for the newest ACTIVITY_RESUMED event (wide
        // window: see latestForegroundPackage() docs).
        private const val FOREGROUND_EVENT_WINDOW_MS = 20 * 60_000L

        // Always allow system components needed to navigate
        val ALWAYS_ALLOWED = setOf(
            "com.android.systemui",
            "com.android.launcher",
            "com.android.launcher3",
            "com.google.android.apps.nexuslauncher",
            "com.android.settings",
            "com.android.permissioncontroller",
            "com.google.android.permissioncontroller",
            "com.android.documentsui",
            "com.android.incallui",
            "com.android.dialer",
            "com.google.android.dialer",
            "com.android.phone",
            "com.android.vending", // Play Store (for updating)
            "com.google.android.gms", // Google Play Services
            "com.android.vending.installer",
            "com.google.android.packageinstaller",
            "com.android.packageinstaller",
            "com.android.intentresolver",
            "com.google.android.intentresolver",
            "be.declippel.firre.study_app" // own package
        )
    }

    private var lastForegroundPackage: String? = null
    private var overlayView: View? = null
    private var remainingTextView: TextView? = null
    private val allowedPackages = HashSet(ALWAYS_ALLOWED)
    private var launcherResolved = false
    private val handler = Handler(Looper.getMainLooper())
    private var broadcastReceiver: BroadcastReceiver? = null
    private val windowManager: WindowManager by lazy {
        getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    /** Resolve the device's home launcher package(s) at runtime so going
     *  Home never counts as a blocked app on OEM launchers (e.g. Samsung,
     *  Xiaomi) that are not in the static ALWAYS_ALLOWED list. */
    private fun ensureLauncherAllowed() {
        if (launcherResolved) return
        launcherResolved = true
        try {
            val homeIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            val resolvers =
                packageManager.queryIntentActivities(homeIntent, PackageManager.MATCH_DEFAULT_ONLY)
            for (info in resolvers) {
                info.activityInfo?.packageName?.let { allowedPackages.add(it) }
            }
        } catch (_: Exception) {
            // Never break blocking because package resolution failed.
        }
    }

    private fun registerSessionEndedReceiver() {
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == ACTION_SESSION_ENDED) {
                    lastForegroundPackage = null
                    hideOverlay()
                }
            }
        }
        broadcastReceiver = receiver
        try {
            val filter = IntentFilter(ACTION_SESSION_ENDED)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(receiver, filter)
            }
        } catch (_: Exception) {
            // Non-critical; the periodic tick checks the session flag too.
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        SessionNotifications.createCompletionChannel(this)
        registerSessionEndedReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: starting foreground service")
        val notification = buildNotification()
        startForeground(NOTIFICATION_ID, notification)

        handler.removeCallbacks(checkRunnable)
        handler.post(checkRunnable)

        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(checkRunnable)
        hideOverlay()
        broadcastReceiver?.let {
            try { unregisterReceiver(it) } catch (_: Exception) {}
        }
        super.onDestroy()
    }

    private val checkRunnable = object : Runnable {
        override fun run() {
            val prefs = getSharedPreferences("focusflow_session", Context.MODE_PRIVATE)
            val active = prefs.getBoolean("active", false)
            val endTime = prefs.getLong("end_time", 0)
            Log.d(TAG, "tick: active=$active now>=endTime=${System.currentTimeMillis() >= endTime}")

            if (!active || System.currentTimeMillis() >= endTime) {
                if (active && System.currentTimeMillis() >= endTime) {
                    // Finish the session natively. The completion alert is
                    // posted here so it still fires when Flutter is frozen or
                    // dead. Clearing the session id keeps a completed session
                    // from being "restored" on the next app launch.
                    SessionNotifications.notifySessionComplete(
                        this@FocusForegroundService
                    )
                    prefs.edit()
                        .putBoolean("active", false)
                        .putBoolean("ended_externally", false)
                        .remove("session_id")
                        .remove("end_time")
                        .remove("total_seconds")
                        .apply()
                }
                hideOverlay()
                stopSelf()
                return
            }

            // Update notification with remaining time
            updateNotification()

            tickBlocking(prefs)

            handler.postDelayed(this, 1000)
        }
    }

    // ------------------------------------------------------------------
    // Blocking
    // ------------------------------------------------------------------

    /**
     * Current foreground app: the most recent ACTIVITY_RESUMED usage event.
     * The window deliberately covers 20 minutes and picks the NEWEST resume:
     * a short sliding window only works when the system flushes usage events
     * instantly, but many devices (and emulators) batch them, so the freshest
     * event inside a wide window is the reliable answer.
     */
    private fun latestForegroundPackage(): String? {
        try {
            val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val now = System.currentTimeMillis()
            val events = usm.queryEvents(now - FOREGROUND_EVENT_WINDOW_MS, now)
            val event = UsageEvents.Event()
            var latest: String? = null
            var latestTs = 0L
            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (event.eventType != UsageEvents.Event.ACTIVITY_RESUMED) continue
                if (event.timeStamp > latestTs) {
                    latestTs = event.timeStamp
                    latest = event.packageName
                }
            }
            Log.d(TAG, "foreground query newest=$latest ageMs=${now - latestTs}")
            return latest
        } catch (e: Exception) {
            // Usage access not granted (or revoked mid-session): no blocking.
            Log.e(TAG, "foreground query failed", e)
            return null
        }
    }

    private fun tickBlocking(prefs: android.content.SharedPreferences) {
        if (!Settings.canDrawOverlays(applicationContext)) {
            Log.w(TAG, "overlay permission missing - blocking disabled")
            return
        }

        val foreground = latestForegroundPackage() ?: return
        ensureLauncherAllowed()

        val allowed = foreground == packageName || allowedPackages.contains(foreground)
        if (!allowed) {
            val whitelist = parseWhitelist(prefs.getString("whitelist", "[]") ?: "[]")
            if (!whitelist.contains(foreground)) {
                Log.d(TAG, "blocked app foreground: $foreground, overlayShowing=${overlayView != null}")
                if (foreground != lastForegroundPackage) {
                    lastForegroundPackage = foreground
                    // Record the attempt in prefs so Flutter can pick it up
                    recordAttempt(prefs, foreground)
                }
                if (overlayView == null) showOverlay()
                return
            }
        }

        // Allowed (own app, system, launcher or whitelisted) app in front:
        // release the screen back to the user.
        lastForegroundPackage = foreground
        if (overlayView != null) hideOverlay()
    }

    private fun recordAttempt(prefs: android.content.SharedPreferences, packageName: String) {
        val attemptsJson = prefs.getString("attempts", "[]") ?: "[]"
        val attempts = JSONArray(attemptsJson)
        val attempt = org.json.JSONObject()
        attempt.put("package", packageName)
        attempt.put("time", System.currentTimeMillis())
        attempts.put(attempt)
        prefs.edit().putString("attempts", attempts.toString()).apply()
    }

    private fun parseWhitelist(json: String): Set<String> {
        val set = HashSet<String>()
        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                set.add(arr.getString(i))
            }
        } catch (_: Exception) {}
        return set
    }

    // ------------------------------------------------------------------
    // Block overlay (WindowManager, no activity launch involved)
    // ------------------------------------------------------------------

    /**
     * Draws a full-screen system overlay (TYPE_APPLICATION_OVERLAY) that sits
     * on top of the blocked app. The window is NOT focusable: it swallows all
     * touches (so the blocked app is unusable) but does not steal key focus.
     * It disappears as soon as an allowed app - e.g. the launcher - is in the
     * foreground, or when the session ends.
     */
    private fun showOverlay() {
        if (overlayView != null) return
        if (!Settings.canDrawOverlays(applicationContext)) return

        try {
            val view = buildOverlayView()
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.OPAQUE
            )
            windowManager.addView(view, params)
            overlayView = view
            Log.d(TAG, "overlay shown")

            handler.removeCallbacks(overlayTickRunnable)
            handler.post(overlayTickRunnable)
        } catch (e: Exception) {
            // Failed to add the window (e.g. permission revoked mid-session);
            // never crash the service.
            Log.e(TAG, "failed to add overlay window", e)
            overlayView = null
            remainingTextView = null
        }
    }

    private fun hideOverlay() {
        val view = overlayView ?: return
        overlayView = null
        remainingTextView = null
        handler.removeCallbacks(overlayTickRunnable)
        try {
            windowManager.removeView(view)
            Log.d(TAG, "overlay hidden")
        } catch (_: Exception) {}
    }

    /** Periodic tick while the overlay is on screen: keeps countdown fresh
     *  and removes the overlay as soon as the session is over. */
    private val overlayTickRunnable = object : Runnable {
        override fun run() {
            val overlay = overlayView ?: return
            val prefs = getSharedPreferences("focusflow_session", Context.MODE_PRIVATE)
            val ended = !prefs.getBoolean("active", false) ||
                    System.currentTimeMillis() >= prefs.getLong("end_time", 0)
            if (ended) {
                hideOverlay()
                return
            }
            updateRemainingTime(prefs.getLong("end_time", 0))
            handler.postDelayed(this, 1000)
        }
    }

    private fun buildOverlayView(): View {
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#E8EAF6")) // Light indigo
            setPadding(48, 48, 48, 48)
            // Absorb touches on empty areas so they never reach the app below
            isClickable = true
        }

        val icon = TextView(this).apply {
            text = "🔒"
            textSize = 64f
            gravity = Gravity.CENTER
        }
        layout.addView(icon)

        val title = TextView(this).apply {
            text = "App Blocked"
            textSize = 28f
            setTextColor(Color.parseColor("#1A237E"))
            gravity = Gravity.CENTER
            setPadding(0, 24, 0, 8)
        }
        layout.addView(title)

        val message = TextView(this).apply {
            text = "This app is blocked during your focus session.\nStay focused!"
            textSize = 16f
            setTextColor(Color.parseColor("#5C6BC0"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 24)
        }
        layout.addView(message)

        val remainingText = TextView(this).apply {
            textSize = 18f
            setTextColor(Color.parseColor("#283593"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 32)
        }
        remainingTextView = remainingText
        layout.addView(remainingText)

        val endSessionButton = Button(this).apply {
            text = "End Session"
            setBackgroundColor(Color.parseColor("#FF7043"))
            setTextColor(Color.WHITE)
            setPadding(48, 24, 48, 24)
            setOnClickListener { endSessionFromOverlay() }
        }
        layout.addView(endSessionButton)

        val homeButton = Button(this).apply {
            text = "Go to Home"
            setBackgroundColor(Color.parseColor("#5C6BC0"))
            setTextColor(Color.WHITE)
            setPadding(48, 24, 48, 24)
            setOnClickListener { goToHome() }
        }
        layout.addView(homeButton)

        return layout
    }

    private fun endSessionFromOverlay() {
        // Keep the session id/end time: if the Flutter process is not alive
        // (e.g. killed by a battery saver), the next app launch can still
        // finalize this session as ended early and show the survey.
        getSharedPreferences("focusflow_session", Context.MODE_PRIVATE)
            .edit()
            .putBoolean("active", false)
            .putBoolean("ended_externally", true)
            .apply()
        hideOverlay()
        try {
            stopSelf()
        } catch (_: Exception) {}

        // Tell the running Flutter engine (if any) that the session was ended
        // from the native overlay, so it marks the session as ended early.
        try {
            MainActivity.notifySessionEndedExternally()
        } catch (_: Exception) {}
    }

    private fun goToHome() {
        hideOverlay()
        try {
            startActivity(Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            })
        } catch (_: Exception) {}
    }

    private fun updateRemainingTime(endTime: Long) {
        val remainingMillis = (endTime - System.currentTimeMillis()).coerceAtLeast(0)
        val minutes = remainingMillis / 60000
        val seconds = (remainingMillis % 60000) / 1000
        remainingTextView?.text =
            "Time remaining: $minutes:${String.format("%02d", seconds)}"
    }

    // ------------------------------------------------------------------
    // Notification
    // ------------------------------------------------------------------

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Focus Session",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows while a focus session is active"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val prefs = getSharedPreferences("focusflow_session", Context.MODE_PRIVATE)
        val endTime = prefs.getLong("end_time", 0)
        val remainingMillis = (endTime - System.currentTimeMillis()).coerceAtLeast(0)
        val remainingMinutes = remainingMillis / 60000

        // Tapping the notification just opens the app; it must never end the
        // session by itself.
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Focus session active")
            .setContentText("$remainingMinutes minutes remaining. Stay focused!")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun updateNotification() {
        val notification = buildNotification()
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, notification)
    }
}
