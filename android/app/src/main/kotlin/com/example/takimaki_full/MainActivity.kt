package hu.takimaki.app

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun onNewIntent(newIntent: Intent) {
        super.onNewIntent(newIntent)
        setIntent(newIntent)
        deviceChannel?.invokeMethod("openWork", null)
    }
    private var deviceChannel: MethodChannel? = null
    private var permissionResult: MethodChannel.Result? = null
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        deviceChannel = MethodChannel(engine.dartExecutor.binaryMessenger, "takimaki/device")
        deviceChannel!!.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "notificationPermission" -> permission(arrayOf(Manifest.permission.POST_NOTIFICATIONS), result)
                    "calendarPermission" -> permission(arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR), result)
                    "calendars" -> {
                        val calendars = mutableListOf<Map<String, Any>>()
                        if (calendarAccess()) contentResolver.query(CalendarContract.Calendars.CONTENT_URI,
                            arrayOf("_id", "calendar_displayName", "account_name"),
                            "calendar_access_level >= ? AND visible = 1", arrayOf("500"), null)?.use { c ->
                            while (c.moveToNext()) calendars.add(mapOf("id" to c.getLong(0), "name" to c.getString(1), "account" to (c.getString(2) ?: "")))
                        }
                        result.success(calendars)
                    }
                    "syncEvent" -> {
                        if (!calendarAccess()) { result.error("calendar_denied", "Naptárhozzáférés szükséges.", null) }
                        else { syncEvent(call.arguments as Map<*, *>); result.success(true) }
                    }
                    "schedule" -> {
                        val data = call.arguments as Map<*, *>
                        val key = data["key"].toString()
                        val prefs = getSharedPreferences("device_workflow", Context.MODE_PRIVATE)
                        val at = (data["at"] as Number).toLong()
                        val json = JSONObject(mapOf("key" to key, "id" to data["id"], "role" to data["role"],
                            "title" to data["title"], "body" to data["body"], "at" to at)).toString()
                        prefs.edit().putString("alarm:$key", json).apply()
                        WorkReminderReceiver.schedule(this, JSONObject(json)); result.success(true)
                    }
                    "cancelWork" -> {
                        val id = call.arguments.toString()
                        val prefs = getSharedPreferences("device_workflow", Context.MODE_PRIVATE)
                        for ((key, raw) in prefs.all) if (key.startsWith("alarm:")) {
                            val data = JSONObject(raw.toString())
                            if (data.optString("id") == id) {
                                WorkReminderReceiver.cancel(this, data.optString("key"))
                                prefs.edit().remove(key).apply()
                            }
                        }
                        result.success(true)
                    }
                    "launchWork" -> { val id = intent.getStringExtra("request_id"); result.success(if (id == null) null else mapOf("id" to id, "role" to intent.getStringExtra("view_role"))); intent.removeExtra("request_id") }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) { result.error("device_error", e.message, null) }
        }
    }
    private fun calendarAccess() = checkSelfPermission(Manifest.permission.READ_CALENDAR) == PackageManager.PERMISSION_GRANTED &&
        checkSelfPermission(Manifest.permission.WRITE_CALENDAR) == PackageManager.PERMISSION_GRANTED
    private fun permission(permissions: Array<String>, result: MethodChannel.Result) {
        if (permissions.first() == Manifest.permission.POST_NOTIFICATIONS && Build.VERSION.SDK_INT < 33) { result.success(true); return }
        if (permissions.all { checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED }) { result.success(true); return }
        if (permissionResult != null) { result.error("busy", "Már folyamatban van egy engedélykérés.", null); return }
        permissionResult = result
        requestPermissions(permissions, 108)
    }
    override fun onRequestPermissionsResult(code: Int, permissions: Array<out String>, results: IntArray) {
        super.onRequestPermissionsResult(code, permissions, results)
        if (code == 108) { permissionResult?.success(results.isNotEmpty() && results.all { it == PackageManager.PERMISSION_GRANTED }); permissionResult = null }
    }
    private fun syncEvent(data: Map<*, *>) {
        val prefs = getSharedPreferences("device_workflow", Context.MODE_PRIVATE)
        val key = "event:${data["calendar"]}:${data["id"]}"
        val old = prefs.getLong(key, -1)
        if (data["cancelled"] == true) {
            if (old >= 0) contentResolver.delete(ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, old), null, null)
            prefs.edit().remove(key).apply(); return
        }
        val values = ContentValues().apply {
            put(CalendarContract.Events.CALENDAR_ID, (data["calendar"] as Number).toLong())
            put(CalendarContract.Events.DTSTART, (data["start"] as Number).toLong())
            put(CalendarContract.Events.DTEND, (data["end"] as Number).toLong())
            put(CalendarContract.Events.TITLE, data["title"].toString())
            put(CalendarContract.Events.DESCRIPTION, data["description"].toString())
            put(CalendarContract.Events.EVENT_LOCATION, data["address"].toString())
            put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
        }
        var eventId = old
        if (old >= 0 && contentResolver.update(ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, old), values, null, null) == 0) eventId = -1
        if (eventId < 0) {
            val uri = contentResolver.insert(CalendarContract.Events.CONTENT_URI, values) ?: throw IllegalStateException("A naptáresemény mentése nem sikerült.")
            eventId = ContentUris.parseId(uri)
            prefs.edit().putLong(key, eventId).apply()
        }
        contentResolver.delete(CalendarContract.Reminders.CONTENT_URI, "event_id = ?", arrayOf(eventId.toString()))
        contentResolver.insert(CalendarContract.Reminders.CONTENT_URI, ContentValues().apply {
            put(CalendarContract.Reminders.EVENT_ID, eventId)
            put(CalendarContract.Reminders.MINUTES, 120)
            put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT)
        })
    }
}

class WorkReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prefs = context.getSharedPreferences("device_workflow", Context.MODE_PRIVATE)
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            for ((key, raw) in prefs.all) if (key.startsWith("alarm:")) {
                val data = JSONObject(raw.toString())
                if (data.optLong("at") > System.currentTimeMillis()) schedule(context, data)
            }
            return
        }
        val key = intent.getStringExtra("key") ?: return
        val raw = prefs.getString("alarm:$key", null) ?: return
        val data = JSONObject(raw)
        prefs.edit().remove("alarm:$key").apply()
        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        if (!flutterPrefs.getBoolean("flutter.notify_push", true) || !flutterPrefs.getBoolean("flutter.session_active", false)) return
        if (flutterPrefs.getString("flutter.active_role", "customer") != data.optString("role")) return
        if (Build.VERSION.SDK_INT >= 33 && context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26) manager.createNotificationChannel(NotificationChannel("work_reminders", "Munkák és értékelések", NotificationManager.IMPORTANCE_DEFAULT))
        val open = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("request_id", data.optString("id")); putExtra("view_role", data.optString("role"))
            this.data = Uri.parse("takimaki://work/${Uri.encode(key)}")
        }
        val pending = PendingIntent.getActivity(context, key.hashCode(), open, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = if (Build.VERSION.SDK_INT >= 26) android.app.Notification.Builder(context, "work_reminders") else android.app.Notification.Builder(context)
        manager.notify(key.hashCode(), builder.setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(data.optString("title")).setContentText(data.optString("body"))
            .setStyle(android.app.Notification.BigTextStyle().bigText(data.optString("body")))
            .setContentIntent(pending).setAutoCancel(true).build())
    }
    companion object {
        private fun pending(context: Context, key: String): PendingIntent {
            val intent = Intent(context, WorkReminderReceiver::class.java).apply {
                data = Uri.parse("takimaki://reminder/${Uri.encode(key)}"); putExtra("key", key)
            }
            return PendingIntent.getBroadcast(context, key.hashCode(), intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }
        fun schedule(context: Context, data: JSONObject) {
            val at = data.optLong("at")
            if (at <= System.currentTimeMillis()) return
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP, at, pending(context, data.optString("key")))
        }
        fun cancel(context: Context, key: String) {
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending(context, key))
        }
    }
}
