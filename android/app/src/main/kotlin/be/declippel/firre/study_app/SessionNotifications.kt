package be.declippel.firre.study_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat

/**
 * Notifications and haptics shared by the foreground service and MainActivity.
 *
 * The completion alert is intentionally native: the Flutter process may be
 * frozen or dead when a session finishes, but the foreground service still
 * knows the wall-clock end time and can alert the user.
 */
object SessionNotifications {
    private const val DONE_CHANNEL_ID = "focusflow_session_done"
    private const val DONE_NOTIFICATION_ID = 1002
    private val VIBRATION_PATTERN = longArrayOf(0, 400, 150, 400)

    fun createCompletionChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        val channel = NotificationChannel(
            DONE_CHANNEL_ID,
            "Session complete",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Alerts you when a focus session is finished"
            // Vibration is triggered explicitly below so it also works when
            // the notification permission was denied.
            enableVibration(false)
            setShowBadge(true)
        }
        manager.createNotificationChannel(channel)
    }

    fun notifySessionComplete(context: Context) {
        createCompletionChannel(context)

        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            2,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, DONE_CHANNEL_ID)
            .setContentTitle("Focus session complete")
            .setContentText("Nice work! Your session is finished.")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .build()

        try {
            context.getSystemService(NotificationManager::class.java)
                ?.notify(DONE_NOTIFICATION_ID, notification)
        } catch (_: SecurityException) {
            // POST_NOTIFICATIONS not granted; the vibration below still runs.
        }

        vibrate(context)
    }

    /** Removes a stale completion notification when a new session starts. */
    fun clearCompletion(context: Context) {
        try {
            context.getSystemService(NotificationManager::class.java)
                ?.cancel(DONE_NOTIFICATION_ID)
        } catch (_: Exception) {
            // Never let notification cleanup affect the session.
        }
    }

    private fun vibrate(context: Context) {
        try {
            val vibrator: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val manager =
                    context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                manager?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }
            if (vibrator == null || !vibrator.hasVibrator()) return

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(
                    VibrationEffect.createWaveform(VIBRATION_PATTERN, -1)
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(VIBRATION_PATTERN, -1)
            }
        } catch (_: Exception) {
            // Haptics are best-effort and must never break completion.
        }
    }
}
