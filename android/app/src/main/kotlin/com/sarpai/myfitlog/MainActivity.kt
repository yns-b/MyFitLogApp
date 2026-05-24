package com.sarpai.myfitlog

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.util.Log
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "custom_workout_notification"

  companion object {
    @JvmStatic var callbacksChannel: MethodChannel? = null
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "showWorkoutNotification" -> {
          val exercise = call.argument<String>("exerciseName") ?: "Egzersiz"
          val currentSet = call.argument<Int>("currentSet") ?: 1
          val totalSets = call.argument<Int>("totalSets") ?: 1
          val weight = call.argument<Double>("weight") ?: 0.0
          val reps = call.argument<Int>("reps") ?: 0
          showWorkoutNotification(exercise, currentSet, totalSets, weight, reps)
          result.success(null)
        }
        "closeWorkoutNotification" -> {
          val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
          nm.cancel(100)
          result.success(null)
        }
        "showTestNotification" -> {
          showTestNotification()
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
    // Channel for callbacks from receiver to Flutter
    callbacksChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "custom_workout_notification_callbacks")
  }

  private fun ensureChannel(id: String, name: String) {
    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      if (nm.getNotificationChannel(id) == null) {
        val channel = NotificationChannel(id, name, NotificationManager.IMPORTANCE_HIGH)
        channel.enableLights(true)
        channel.lightColor = Color.CYAN
        nm.createNotificationChannel(channel)
      }
    }
  }

  private fun showTestNotification() {
    val channelId = "test_channel"
    ensureChannel(channelId, "Test Kanalı")
    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val notif = NotificationCompat.Builder(this, channelId)
      .setSmallIcon(R.drawable.ic_scale)
      .setContentTitle("Test Bildirimi")
      .setContentText("Bu bir test bildirimi (native)")
      .setPriority(NotificationCompat.PRIORITY_HIGH)
      .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
      .setDefaults(NotificationCompat.DEFAULT_ALL)
      .build()
    nm.notify(9999, notif)
  }

  private fun showWorkoutNotification(exercise: String, currentSet: Int, totalSets: Int, weight: Double, reps: Int) {
    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val channelId = "quick_set_progress_v2"
    ensureChannel(channelId, "Hızlı Set İlerlemesi (Yeni)")

    try {
      val views = RemoteViews(packageName, R.layout.notification_workout)
      views.setTextViewText(R.id.titleText, "$currentSet/$totalSets $exercise")
      views.setTextViewText(R.id.kgValue, String.format("%.1f kg", weight))
      views.setTextViewText(R.id.repsValue, String.format("%d tkr", reps))

      // PendingIntent helpers
      fun actionIntent(actionName: String): PendingIntent {
        val intent = Intent(this, WorkoutActionReceiver::class.java).apply { setAction(actionName) }
        return PendingIntent.getBroadcast(this, actionName.hashCode(), intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
      }

      views.setOnClickPendingIntent(R.id.kgPlus, actionIntent("WEIGHT_PLUS"))
      views.setOnClickPendingIntent(R.id.kgMinus, actionIntent("WEIGHT_MINUS"))
      views.setOnClickPendingIntent(R.id.repsPlus, actionIntent("REPS_PLUS"))
      views.setOnClickPendingIntent(R.id.repsMinus, actionIntent("REPS_MINUS"))
      views.setOnClickPendingIntent(R.id.saveBtn, actionIntent("SAVE_SET"))
      views.setOnClickPendingIntent(R.id.closeBtn, actionIntent("CLOSE"))

      val notification = NotificationCompat.Builder(this, channelId)
        .setSmallIcon(R.drawable.ic_scale)
        .setContentTitle("$currentSet/$totalSets $exercise")
        .setContentText(String.format("+ %.1f kg   -    + %d tkr   -", weight, reps))
        .setOngoing(true)
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        .setStyle(NotificationCompat.DecoratedCustomViewStyle())
        .setCustomContentView(views)
        .setCustomBigContentView(views)
        .setOnlyAlertOnce(true)
        .setDefaults(NotificationCompat.DEFAULT_ALL)
        .build()

      nm.notify(100, notification)
    } catch (e: Exception) {
      Log.e("CustomNotif", "RemoteViews failed, falling back", e)
      val fallback = NotificationCompat.Builder(this, channelId)
        .setSmallIcon(R.drawable.ic_scale)
        .setContentTitle("$currentSet/$totalSets $exercise")
        .setContentText(String.format("%.1f kg × %d tkr", weight, reps))
        .setOngoing(true)
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        .setOnlyAlertOnce(true)
        .setDefaults(NotificationCompat.DEFAULT_ALL)
        .build()
      nm.notify(100, fallback)
    }
  }
}

class WorkoutActionReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    val channel = MainActivity.callbacksChannel ?: return
    when (intent.action) {
      "WEIGHT_PLUS" -> channel.invokeMethod("weight_plus", null)
      "WEIGHT_MINUS" -> channel.invokeMethod("weight_minus", null)
      "REPS_PLUS" -> channel.invokeMethod("reps_plus", null)
      "REPS_MINUS" -> channel.invokeMethod("reps_minus", null)
      "SAVE_SET" -> channel.invokeMethod("save_set", null)
      "CLOSE" -> channel.invokeMethod("close", null)
    }
  }
} 