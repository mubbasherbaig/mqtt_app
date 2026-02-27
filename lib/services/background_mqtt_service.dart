// lib/services/background_mqtt_service.dart
//
// SIMPLIFIED approach — instead of running MQTT in a separate isolate
// (which can't share state with the UI), we:
//  1. Start a foreground service just to keep the Android process alive
//  2. The existing MqttService singleton in the main isolate continues running
//  3. On app open, MqttService.init() auto-connects from saved prefs
//
// This is the correct architecture for Flutter + MQTT on Android.

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String _kChannelId      = 'mqtt_fg_channel';
const int    _kNotificationId = 888;

/// Call once in main() before runApp().
Future<void> initBackgroundService() async {
  final service = FlutterBackgroundService();

  // Create low-priority notification channel
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
    _kChannelId,
    'MQTT Connection',
    description: 'Keeps your MQTT connection active',
    importance: Importance.low,
    playSound: false,
    enableVibration: false,
  ));

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: _kNotificationId.toString(),
      initialNotificationTitle: 'MQTT Panel',
      initialNotificationContent: 'Connection active',
      foregroundServiceNotificationId: _kNotificationId,
      foregroundServiceTypes: [AndroidForegroundType.connectedDevice],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: _onStart,
      onBackground: _onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// This background entry point does ONE thing: keeps the process alive.
/// The real MQTT connection lives in the main isolate.
@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Update notification text
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'MQTT Panel',
      content: 'Connection active in background',
    );
  }

  // Listen for stop command from UI
  service.on('stop').listen((_) => service.stopSelf());

  // Heartbeat to prevent the service from being killed
  Timer.periodic(const Duration(seconds: 20), (_) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'MQTT Panel',
        content: 'Active — ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      );
    }
  });
}

/// Start the foreground service to keep the process alive.
/// Call this when user connects to a broker.
Future<void> startBackgroundKeepAlive() async {
  final service = FlutterBackgroundService();
  final running = await service.isRunning();
  if (!running) {
    await service.startService();
  }
}

/// Stop the foreground service.
/// Call this when user intentionally disconnects.
Future<void> stopBackgroundKeepAlive() async {
  final service = FlutterBackgroundService();
  service.invoke('stop');
}