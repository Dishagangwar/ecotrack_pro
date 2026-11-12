import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'eco_channel';

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  static IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  /// Sets up timezones, the plugin and the Android channel.
  ///
  /// Deliberately does NOT ask for permission: on Android the system dialog
  /// needs a resumed Activity, and main() runs before runApp(), so a request
  /// made here is silently dropped. Call [requestPermissions] from the UI.
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Permissions are requested later, explicitly, so turn off the
    // automatic request that would otherwise fire during initialize().
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      'Eco Notifications',
      description: 'EcoTrack reminders',
      importance: Importance.max,
    );

    await _android?.createNotificationChannel(channel);
  }

  /// Asks the user for notification permission. Safe to call more than once:
  /// Android only shows the dialog while the permission is still undecided.
  ///
  /// Must be called once the app is on screen, not from main().
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      return await _android?.requestNotificationsPermission() ?? false;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      return await _ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  /// True once the user has allowed notifications.
  static Future<bool> areNotificationsEnabled() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    return await _android?.areNotificationsEnabled() ?? false;
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

    // Android 12+ refuses exact alarms unless the user granted them in
    // Settings, and throws if we ask anyway. Fall back to inexact, which
    // needs no permission and is accurate enough for a daily reminder.
    final canBeExact = !kIsWeb && Platform.isAndroid
        ? (await _android?.canScheduleExactNotifications() ?? false)
        : true;

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
      androidScheduleMode: canBeExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }
}
