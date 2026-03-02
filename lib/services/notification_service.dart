// lib/services/notification_service.dart
//
// Singleton wrapper around flutter_local_notifications.
// Already in pubspec.yaml via flutter_background_service dependency.
// Call NotificationService.init() once in main(), then
// NotificationService.show(title, body) from any live panel.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static int _nextId = 1;

  static const _channelId   = 'mqtt_panel_alerts';
  static const _channelName = 'MQTT Panel Alerts';

  /// Call once in main() before runApp().
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);

    // Create the high-importance channel for panel alerts
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Alerts from MQTT panel widgets',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _ready = true;
  }

  /// Fire a notification. Safe to call from any isolate/widget.
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    if (!_ready) return;

    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _plugin.show(_nextId++, title, body, details);

    // Wrap ID to avoid overflow
    if (_nextId > 10000) _nextId = 1;
  }
}