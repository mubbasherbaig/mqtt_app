// lib/services/background_mqtt_service.dart
//
// TRUE persistent background MQTT + notification service.
//
// Architecture:
//   - Background isolate connects to ALL brokers independently
//   - Reads connections from SharedPreferences key 'mqtt_connections'
//   - Subscribes to every notification-enabled panel topic
//   - Fires notifications directly — no dependency on UI isolate
//   - Survives: swipe-to-close, screen off, doze mode, device reboot
//   - Does NOT survive: force stop (Android design, nothing can)

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kFgChannelId   = 'mqtt_fg_channel';
const String _kAlertChannelId = 'mqtt_alert_channel';
const int    _kFgNotifId     = 888;

// ── Public API ─────────────────────────────────────────────────

/// Call once in main() before runApp().
Future<void> initBackgroundService() async {
  final service = FlutterBackgroundService();
  final plugin  = FlutterLocalNotificationsPlugin();

  // Persistent low-priority channel (service running indicator)
  await plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
    _kFgChannelId,
    'MQTT Connection',
    description: 'Shows while MQTT is active in background',
    importance: Importance.low,
    playSound: false,
    enableVibration: false,
  ));

  // High-priority channel for panel alert notifications
  await plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
    _kAlertChannelId,
    'MQTT Alerts',
    description: 'Panel notifications from MQTT messages',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  ));

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _bgMain,
      autoStart: true,             // restart after device reboot
      isForegroundMode: true,      // START_STICKY — restarts after swipe
      notificationChannelId: _kFgChannelId,
      initialNotificationTitle: 'MQTT Panel',
      initialNotificationContent: 'Starting...',
      foregroundServiceNotificationId: _kFgNotifId,
      foregroundServiceTypes: [AndroidForegroundType.connectedDevice],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: _bgMain,
      onBackground: _iosBgHandler,
    ),
  );
}

/// Start the service. Call after initBackgroundService() in main().
Future<void> startBackgroundKeepAlive() async {
  final svc = FlutterBackgroundService();
  if (!await svc.isRunning()) await svc.startService();
}

/// Call after adding/editing panels or connections so service reloads.
void refreshBackgroundService() {
  FlutterBackgroundService().invoke('refresh');
}

/// Stop the service — only call on intentional full disconnect.
void stopBackgroundKeepAlive() {
  FlutterBackgroundService().invoke('stop');
}

// ── iOS background handler ─────────────────────────────────────

@pragma('vm:entry-point')
Future<bool> _iosBgHandler(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// ── Background isolate entry point ─────────────────────────────

@pragma('vm:entry-point')
void _bgMain(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Promote to foreground immediately
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: 'MQTT Panel',
      content: 'Connecting...',
    );
  }

  // Init local notifications inside background isolate
  final notif = FlutterLocalNotificationsPlugin();
  await notif.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ));

  // State
  final Map<String, MqttServerClient> clients = {};
  final List<StreamSubscription> msgSubs = [];
  int notifId = 1000;

  // ── Fire a panel alert ──────────────────────────────────────
  Future<void> fire(String title, String body) async {
    try {
      await notif.show(
        notifId++,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _kAlertChannelId,
            'MQTT Alerts',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
      );
    } catch (_) {}
  }

  // ── Disconnect and clear everything ─────────────────────────
  Future<void> disconnectAll() async {
    for (final sub in msgSubs) { try { await sub.cancel(); } catch (_) {} }
    msgSubs.clear();
    for (final c in clients.values) { try { c.disconnect(); } catch (_) {} }
    clients.clear();
  }

  // ── Build the effective topic (apply dashboard prefix) ──────
  String effectiveTopic(String rawTopic, String dashboardPrefix, bool disablePrefix) {
    if (disablePrefix || dashboardPrefix.isEmpty || rawTopic.isEmpty) return rawTopic;
    final clean = rawTopic.startsWith('/') ? rawTopic.substring(1) : rawTopic;
    return '$dashboardPrefix$clean';
  }

  // ── MQTT wildcard topic matching ─────────────────────────────
  bool topicMatches(String filter, String incoming) {
    if (filter == incoming) return true;
    final fp = filter.split('/');
    final tp = incoming.split('/');
    for (int i = 0; i < fp.length; i++) {
      if (fp[i] == '#') return true;
      if (i >= tp.length) return false;
      if (fp[i] != '+' && fp[i] != tp[i]) return false;
    }
    return fp.length == tp.length;
  }

  // ── JSON path extraction ─────────────────────────────────────
  String extractJson(String payload, String path) {
    if (path.isEmpty) return payload;
    try {
      dynamic obj = jsonDecode(payload);
      for (final key in path.split('.')) {
        if (obj is Map) obj = obj[key]; else return payload;
      }
      return obj?.toString() ?? payload;
    } catch (_) { return payload; }
  }

  // ── Load connections + panels and connect ───────────────────
  Future<void> connectAll() async {
    await disconnectAll();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('mqtt_connections'); // StorageService key
    if (raw == null) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'MQTT Panel', content: 'No connections configured',
        );
      }
      return;
    }

    List<dynamic> connections;
    try { connections = jsonDecode(raw); } catch (_) { return; }

    int connectedCount = 0;

    for (final conn in connections) {
      final host     = conn['broker']   as String? ?? '';
      final port     = int.tryParse(conn['port']?.toString() ?? '1883') ?? 1883;
      final clientId = conn['clientId'] as String? ?? '';
      final username = conn['username'] as String? ?? '';
      final password = conn['password'] as String? ?? '';

      if (host.isEmpty) continue;

      // Collect all notification-enabled panels from all dashboards
      final List<Map<String, dynamic>> notifPanels = [];
      final dashboards = conn['dashboards'] as List? ?? [];

      for (final dashboard in dashboards) {
        // Dashboard prefix = dashboard name (same logic as _DashboardTabBodyState)
        final dashName   = dashboard['name'] as String? ?? '';
        final dashPrefix = dashName.isEmpty ? '' : dashName;

        final panels = dashboard['panels'] as List? ?? [];
        for (final panel in panels) {
          if (panel['enableNotification'] != true) continue;
          // Attach resolved prefix for use during message handling
          final enriched = Map<String, dynamic>.from(panel);
          enriched['_dashboardPrefix'] = dashPrefix;
          notifPanels.add(enriched);
        }
      }

      if (notifPanels.isEmpty) continue;

      // Connect to this broker
      try {
        final bgId = clientId.isNotEmpty
            ? '${clientId}_bg'
            : 'mqbg_${host.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch % 10000}';

        final client = MqttServerClient.withPort(host, bgId, port);
        client.logging(on: false);
        client.keepAlivePeriod      = 30;
        client.connectTimeoutPeriod = 10000;
        client.autoReconnect        = true;
        client.resubscribeOnAutoReconnect = true;

        final connMsg = MqttConnectMessage()
            .withClientIdentifier(bgId)
            .startClean()
            .withWillQos(MqttQos.atMostOnce);
        if (username.isNotEmpty) connMsg.authenticateAs(username, password);
        client.connectionMessage = connMsg;

        final status = await client.connect();
        if (status?.state != MqttConnectionState.connected) continue;

        connectedCount++;
        clients['$host:$port'] = client;

        // Subscribe to every notification-enabled panel topic
        final Set<String> subscribedTopics = {};
        for (final panel in notifPanels) {
          final rawTopic   = panel['topic'] as String? ?? '';
          final disablePrefix = panel['disableDashboardPrefix'] == true;
          final dashPrefix = panel['_dashboardPrefix'] as String? ?? '';

          // Primary topic
          final topic = effectiveTopic(rawTopic, dashPrefix, disablePrefix);
          if (topic.isNotEmpty && !subscribedTopics.contains(topic)) {
            try { client.subscribe(topic, MqttQos.atLeastOnce); } catch (_) {}
            subscribedTopics.add(topic);
          }

          // subscribeTopic (for interactive panels like Slider, Combo, Radio)
          final rawSub = panel['subscribeTopic'] as String? ?? '';
          final subTopic = effectiveTopic(rawSub, dashPrefix, disablePrefix);
          if (subTopic.isNotEmpty && !subscribedTopics.contains(subTopic)) {
            try { client.subscribe(subTopic, MqttQos.atLeastOnce); } catch (_) {}
            subscribedTopics.add(subTopic);
          }
        }

        // Track previous payloads per topic for transition detection
        final Map<String, String> lastPayloads = {};

        // Listen for incoming messages
        final sub = client.updates!.listen((msgs) async {
          for (final msg in msgs) {
            final incomingTopic = msg.topic;
            final payload = MqttPublishPayload.bytesToStringAsString(
                (msg.payload as MqttPublishMessage).payload.message);

            // Find which panels this message applies to
            for (final panel in notifPanels) {
              final rawTopic   = panel['topic'] as String? ?? '';
              final rawSub     = panel['subscribeTopic'] as String? ?? '';
              final disablePrefix = panel['disableDashboardPrefix'] == true;
              final dashPrefix = panel['_dashboardPrefix'] as String? ?? '';
              final panelType  = panel['type'] as String? ?? '';
              final panelLabel = panel['label'] as String?
                  ?? panel['panelName'] as String?
                  ?? panelType;

              final topic    = effectiveTopic(rawTopic,  dashPrefix, disablePrefix);
              final subTopic = effectiveTopic(rawSub,    dashPrefix, disablePrefix);

              // Determine which topic this panel listens to for notifications
              // Interactive panels (Slider, Combo, Radio) use subscribeTopic
              // All others use topic
              final bool isInteractive = ['Slider', 'Combo Box', 'Radio Buttons'].contains(panelType);
              final String listenTopic = isInteractive && subTopic.isNotEmpty ? subTopic : topic;

              if (listenTopic.isEmpty) continue;
              if (!topicMatches(listenTopic, incomingTopic)) continue;

              // For interactive panels, only notify if subscribeTopic is different from publish topic
              if (isInteractive) {
                if (rawSub.isEmpty || rawSub == rawTopic) continue;
              }

              // Extract JSON if needed
              final jsonPath = panel['jsonPath'] as String? ?? '';
              final extracted = extractJson(payload, jsonPath);
              final prevPayload = lastPayloads[listenTopic] ?? '';

              // Panel-type-specific notification logic
              switch (panelType) {
                case 'LED Indicator':
                  final payloadOn = panel['payloadOn'] as String? ?? '1';
                  if (prevPayload != payloadOn && extracted == payloadOn) {
                    await fire(panelLabel, 'Turned ON');
                  }
                  break;

                case 'Node Status':
                  final payloadOnline = panel['payloadOnline'] as String? ?? 'online';
                  if (prevPayload == payloadOnline && extracted != payloadOnline) {
                    await fire(panelLabel, 'Device went OFFLINE');
                  }
                  break;

                case 'Multi-State Indicator':
                  if (extracted != prevPayload) {
                    final items = panel['items'] as List? ?? [];
                    final matched = items.firstWhere(
                          (i) => i['payload']?.toString() == extracted,
                      orElse: () => <String, dynamic>{},
                    );
                    final label = (matched as Map)['label']?.toString() ?? extracted;
                    await fire(panelLabel, 'State changed to: $label');
                  }
                  break;

                case 'Combo Box':
                case 'Radio Buttons':
                  final items = panel['items'] as List? ?? [];
                  final matched = items.firstWhere(
                        (i) => i['payload']?.toString() == extracted,
                    orElse: () => <String, dynamic>{},
                  );
                  if ((matched as Map).isNotEmpty) {
                    final label = matched['label']?.toString() ?? extracted;
                    await fire(panelLabel, 'Selection changed to: $label');
                  }
                  break;

                case 'Image':
                  await fire(panelLabel, 'New image received');
                  break;

                case 'URI Launcher':
                  await fire(panelLabel, 'New URL: $extracted');
                  break;

                case 'Slider':
                  await fire(panelLabel, 'Value: $extracted');
                  break;

                default:
                // Gauge, Progress, and all others — notify on every value
                  await fire(panelLabel, '$extracted');
              }

              lastPayloads[listenTopic] = extracted;
            }
          }
        });

        msgSubs.add(sub);
      } catch (_) {
        continue;
      }
    }

    // Update persistent notification
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'MQTT Panel',
        content: connectedCount > 0
            ? '$connectedCount broker${connectedCount != 1 ? 's' : ''} active'
            : 'Waiting for connections...',
      );
    }
  }

  // ── Initial connect ─────────────────────────────────────────
  await connectAll();

  // ── Command handlers ────────────────────────────────────────
  service.on('stop').listen((_) async {
    await disconnectAll();
    service.stopSelf();
  });

  service.on('refresh').listen((_) async {
    await connectAll();
  });

  // ── Heartbeat every 30s ─────────────────────────────────────
  // Updates notification + checks/reconnects dropped clients
  Timer.periodic(const Duration(seconds: 30), (_) async {
    if (service is AndroidServiceInstance) {
      final t = DateTime.now();
      final ts = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      service.setForegroundNotificationInfo(
        title: 'MQTT Panel',
        content: '${clients.length} broker${clients.length != 1 ? 's' : ''} | $ts',
      );
    }

    // Reconnect any dropped clients
    bool anyDropped = false;
    for (final c in clients.values) {
      if (c.connectionStatus?.state != MqttConnectionState.connected) {
        anyDropped = true;
        break;
      }
    }
    if (anyDropped) await connectAll();
  });
}