package be.declippel.firre.study_app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import java.io.ByteArrayOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "focusflow/blocker"
    private val appsChannelName = "focusflow/apps"

    // App enumeration + icon encoding is expensive; run it off the main
    // thread. MethodChannel results must be posted back to the main thread.
    private val appsExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        // Live reference to the blocker channel so other components in this
        // process (e.g. the foreground service, which has no engine
        // reference) can push events into Dart.
        @Volatile
        var blockerChannel: MethodChannel? = null
            private set

        // No-op result so invoking into Dart can never crash the caller when
        // Dart is not listening (e.g. no active session).
        private val SILENT_RESULT = object : MethodChannel.Result {
            override fun success(result: Any?) {}
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
            override fun notImplemented() {}
        }

        const val ACTION_SESSION_ENDED = "focusflow.SESSION_ENDED"

        // Debug-only hook so instrumentation (adb shell am start) can kick off
        // a session through the exact same code path as the Flutter channel.
        // Ignored unless the installed build is debuggable.
        const val ACTION_DEBUG_START_SESSION = "focusflow.DEBUG_START_SESSION"

        fun notifySessionEndedExternally() {
            blockerChannel?.invokeMethod("onSessionEndedExternally", null, SILENT_RESULT)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleDebugIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDebugIntent(intent)
    }

    private fun handleDebugIntent(intent: Intent?) {
        android.util.Log.d("FocusFlowBlocker", "handleDebugIntent action=${intent?.action}")
        if (intent?.action != ACTION_DEBUG_START_SESSION) return
        val debuggable =
            applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE != 0
        if (!debuggable) return

        val now = System.currentTimeMillis()
        startSessionInternal(
            sessionId = "emulator-debug",
            endTimeMillis = now + 10 * 60_000,
            totalSeconds = 600,
            whitelistJson = "[]"
        )
    }

    internal fun startSessionInternal(
        sessionId: String,
        endTimeMillis: Long,
        totalSeconds: Int,
        whitelistJson: String
    ) {
        // Always keep FocusFlow itself allowed so a session can
        // never block the app that is running it.
        val whitelist = JSONArray(whitelistJson)
        var hasSelf = false
        for (i in 0 until whitelist.length()) {
            if (whitelist.optString(i) == packageName) {
                hasSelf = true
                break
            }
        }
        if (!hasSelf) whitelist.put(packageName)

        val prefs = getSharedPreferences("focusflow_session", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("active", true)
            .putString("session_id", sessionId)
            .putLong("end_time", endTimeMillis)
            .putInt("total_seconds", totalSeconds)
            .putString("whitelist", whitelist.toString())
            .putLong("start_time", System.currentTimeMillis())
            // Never leak attempts from a previous session into this one.
            .putString("attempts", "[]")
            .apply()

        val serviceIntent = Intent(this, FocusForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val blockerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        MainActivity.blockerChannel = blockerChannel

        blockerChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isUsageAccessGranted" -> result.success(isUsageAccessGranted())
                "canDrawOverlays" -> result.success(Settings.canDrawOverlays(this))
                "openUsageAccessSettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    } catch (_: Exception) {}
                    result.success(null)
                }
                "openOverlaySettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                    }
                    result.success(null)
                }
                "startSession" -> {
                    val sessionId = call.argument<String>("sessionId")!!
                    val endTimeMillis = call.argument<Long>("endTimeMillis")!!
                    val totalSeconds = call.argument<Int>("totalSeconds")!!
                    val whitelistJson = call.argument<String>("whitelist")!!

                    startSessionInternal(sessionId, endTimeMillis, totalSeconds, whitelistJson)
                    result.success(null)
                }
                "endSession" -> {
                    val prefs = getSharedPreferences("focusflow_session", Context.MODE_PRIVATE)
                    prefs.edit().putBoolean("active", false).apply()

                    stopService(Intent(this, FocusForegroundService::class.java))

                    // Let the blocker service dismiss any overlay shown.
                    try {
                        sendBroadcast(Intent(ACTION_SESSION_ENDED).setPackage(packageName))
                    } catch (_: Exception) {}

                    result.success(null)
                }
                "updateWhitelist" -> {
                    val whitelistJson = call.argument<String>("whitelist")!!
                    val whitelist = JSONArray(whitelistJson)
                    var hasSelf = false
                    for (i in 0 until whitelist.length()) {
                        if (whitelist.optString(i) == packageName) {
                            hasSelf = true
                            break
                        }
                    }
                    if (!hasSelf) whitelist.put(packageName)

                    val prefs = getSharedPreferences("focusflow_session", Context.MODE_PRIVATE)
                    prefs.edit().putString("whitelist", whitelist.toString()).apply()
                    result.success(null)
                }
                "consumePendingAttempts" -> {
                    // Returns and clears the block attempts recorded natively
                    // during the session so the Flutter side can persist them.
                    val prefs = getSharedPreferences("focusflow_session", Context.MODE_PRIVATE)
                    val attemptsJson = prefs.getString("attempts", "[]") ?: "[]"
                    val packages = ArrayList<String>()
                    try {
                        val attempts = JSONArray(attemptsJson)
                        for (i in 0 until attempts.length()) {
                            val attempt = attempts.optJSONObject(i) ?: continue
                            val pkg = attempt.optString("package")
                            if (pkg.isNotEmpty()) packages.add(pkg)
                        }
                    } catch (_: Exception) {}
                    prefs.edit().putString("attempts", "[]").apply()
                    result.success(packages)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appsChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLaunchableApps" -> {
                        appsExecutor.execute {
                            try {
                                val apps = getLaunchableApps()
                                mainHandler.post { result.success(apps) }
                            } catch (e: Exception) {
                                mainHandler.post {
                                    result.error("APP_LIST_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getLaunchableApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null).addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfoList = pm.queryIntentActivities(mainIntent, 0)

        return resolveInfoList
            .filter { it.activityInfo.packageName != packageName }
            .map { info ->
                val appName = info.loadLabel(pm).toString()
                val pkgName = info.activityInfo.packageName
                val icon = try {
                    drawableToBase64(info.loadIcon(pm))
                } catch (e: Exception) {
                    null
                }
                mapOf(
                    "packageName" to pkgName,
                    "appName" to appName,
                    "iconBase64" to icon
                )
            }
            .distinctBy { it["packageName"] }
            .sortedBy { (it["appName"] as String).lowercase() }
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val bitmap: Bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val bmp = Bitmap.createBitmap(
                drawable.intrinsicWidth.coerceAtLeast(1),
                drawable.intrinsicHeight.coerceAtLeast(1),
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }
        val scaled = Bitmap.createScaledBitmap(bitmap, 96, 96, true)
        val outputStream = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
        return Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
    }

    private fun isUsageAccessGranted(): Boolean {
        // queryEvents() silently returns EMPTY data (no exception!) when the
        // "Usage access" app op is revoked - seen on MIUI. So probe the
        // AppOps layer directly instead of inferring from query results.
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            ) == AppOpsManager.MODE_ALLOWED
        } catch (_: Exception) {
            false
        }
    }
}
