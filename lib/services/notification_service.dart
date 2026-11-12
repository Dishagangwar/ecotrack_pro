import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'eco_channel';

  static Future<void> init() async {
  // 🔹 Initialize timezones
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // 👈 REQUIRED

  const androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // 🔹 iOS / macOS need their own settings or initialize() throws
  const darwinInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: darwinInit,
    macOS: darwinInit,
  );

  await _plugin.initialize(initSettings);

  // 🔹 Create notification channel
  const AndroidNotificationChannel channel =
      AndroidNotificationChannel(
    _channelId,
    'Eco Notifications',
    description: 'EcoTrack reminders',
    importance: Importance.max,
  );

  final androidPlugin =
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(channel);

  // 🔹 Request permission (Android 13+)
  // These resolve to null on iOS, so the calls are simply skipped there.
  await androidPlugin?.requestNotificationsPermission();
  await androidPlugin?.requestExactAlarmsPermission();

  // 🔹 Request permission (iOS)
  await _plugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

}



  static Future<void> showNow({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Eco Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> scheduleAt({
  required int hour,
  required int minute,
  required String title,
  required String body,
}) async {
  final now = tz.TZDateTime.now(tz.local);

  tz.TZDateTime scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  // If selected time already passed → schedule tomorrow
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  await _plugin.zonedSchedule(
    100,
    title,
    body,
    scheduled,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Eco Notifications',
        channelDescription: 'EcoTrack reminders & summaries',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ FIX
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // ✅ makes it repeat daily
  );
}

}
