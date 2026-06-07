import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Schedules local "time to water" reminders for plants.
///
/// Local notifications only — no push/server involvement. All methods are
/// defensive: a failure here must never break the plant create/update/delete
/// flow, so everything is wrapped in try/catch and silently degrades.
class ReminderService {
  ReminderService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'plant_care_reminders';
  static const _channelName = 'Plant care reminders';
  static const _channelDescription = 'Reminders to water and care for your plants';

  static bool _initialized = false;
  static bool _permissionRequested = false;

  /// Initialise the plugin and timezone database. Call once at startup.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (_) {
      // Notifications are non-critical; continue without them.
    }
  }

  /// Requests the notification permission once (Android 13+). Safe to call
  /// repeatedly; returns true when notifications are (or are assumed) allowed.
  static Future<bool> ensurePermission() async {
    if (_permissionRequested) return true;
    _permissionRequested = true;
    try {
      final android =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      // Returns null on Android < 13, where the permission isn't needed.
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Schedules a watering reminder for [plantId], firing [intervalDays] from now.
  static Future<void> scheduleWateringReminder({
    required String plantId,
    required String plantName,
    required int intervalDays,
  }) async {
    if (intervalDays <= 0) return;
    try {
      await init();
      await ensurePermission();

      final when = tz.TZDateTime.now(tz.UTC).add(Duration(days: intervalDays));

      await _plugin.zonedSchedule(
        _notificationId(plantId),
        'Time to water $plantName',
        'Your plant needs some attention.',
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Swallow — never block the plant flow on a scheduling failure.
    }
  }

  /// Cancels the watering reminder for [plantId].
  static Future<void> cancelReminder(String plantId) async {
    try {
      await _plugin.cancel(_notificationId(plantId));
    } catch (_) {
      // Ignore.
    }
  }

  /// Cancels and re-schedules the watering reminder (e.g. when the interval
  /// changed). Equivalent to cancel + schedule.
  static Future<void> rescheduleReminder({
    required String plantId,
    required String plantName,
    required int intervalDays,
  }) async {
    await cancelReminder(plantId);
    await scheduleWateringReminder(
      plantId: plantId,
      plantName: plantName,
      intervalDays: intervalDays,
    );
  }

  /// Stable, positive notification id derived from the plant id so that
  /// cancel/reschedule target the same notification.
  static int _notificationId(String plantId) => plantId.hashCode & 0x7fffffff;
}
