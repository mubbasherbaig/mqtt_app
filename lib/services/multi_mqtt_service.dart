// lib/services/multi_mqtt_service.dart
//
// Manages one independent MQTT client per broker connection.
// All connections run simultaneously — connecting, subscribing, and receiving
// messages independently. The UI observes per-connection state via
// getState(host, port) and per-topic values via lastValue(host, port, topic).

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mqtt_service.dart' show AppMqttState;
import 'mqtt_service_proxy.dart';

// AppMqttState is defined in mqtt_service.dart — imported above.

// ── Key for identifying a connection ──────────────────────────
// We use "host:port" as a unique key.
String _connKey(String host, int port) => '$host:$port';

// ── Single-connection manager (internal) ──────────────────────
class _MqttClient {
  final String host;
  final int port;
  final String clientId;
  final String username;
  final String password;

  MqttServerClient? _client;
  AppMqttState state = AppMqttState.disconnected;
  String errorMessage = '';

  final Map<String, List<void Function(String)>> _listeners = {};
  final Map<String, String> _topicValues = {};

  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;
  int _reconnectAttempts = 0;
  bool _connectedHandled = false;

  // Called whenever state changes so MultiMqttService can notify its listeners
  final void Function() onStateChanged;

  _MqttClient({
    required this.host,
    required this.port,
    required this.clientId,
    required this.username,
    required this.password,
    required this.onStateChanged,
  });

  bool get isConnected => state == AppMqttState.connected;
  String? lastValue(String topic) => _topicValues[topic];

  Future<void> connect() async {
    _intentionalDisconnect = false;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    await _doConnect();
  }

  Future<void> disconnect({bool intentional = true}) async {
    _intentionalDisconnect = intentional;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    try { _client?.disconnect(); } catch (_) {}
    _client = null;
    if (intentional) {
      _listeners.clear();
      _topicValues.clear();
    }
    _setState(AppMqttState.disconnected);
  }

  Future<void> resumeIfNeeded() async {
    if (_intentionalDisconnect) return;
    if (state == AppMqttState.connected || state == AppMqttState.connecting) return;
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    await _doConnect();
  }

  void publish(String topic, String payload, {int qos = 0, bool retain = false}) {
    if (_client == null || !isConnected) return;
    final builder = MqttClientPayloadBuilder()..addString(payload);
    final mqttQos = qos == 1 ? MqttQos.atLeastOnce
        : qos == 2 ? MqttQos.exactlyOnce
        : MqttQos.atMostOnce;
    try {
      _client!.publishMessage(topic, mqttQos, builder.payload!, retain: retain);
    } catch (e) {
      debugPrint('[MQTT:$host] Publish error: $e');
    }
  }

  VoidCallback subscribe(String topic, void Function(String) onMessage) {
    _listeners.putIfAbsent(topic, () => []);
    if (_listeners[topic]!.isEmpty && isConnected) {
      try { _client!.subscribe(topic, MqttQos.atLeastOnce); } catch (_) {}
    }
    _listeners[topic]!.add(onMessage);
    if (_topicValues.containsKey(topic)) {
      Future.microtask(() => onMessage(_topicValues[topic]!));
    }
    return () {
      _listeners[topic]?.remove(onMessage);
      if (_listeners[topic]?.isEmpty ?? true) {
        _listeners.remove(topic);
        if (isConnected) {
          try { _client!.unsubscribe(topic); } catch (_) {}
        }
      }
    };
  }

  Future<void> _doConnect() async {
    _connectedHandled = false;
    _setState(AppMqttState.connecting);

    try {
      final id = clientId.isEmpty
          ? 'mqttpanel_${host.replaceAll('.', '_')}_${DateTime.now().millisecondsSinceEpoch}'
          : clientId;

      _client = MqttServerClient.withPort(host, id, port);
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = 20;
      _client!.connectTimeoutPeriod = 8000;
      _client!.autoReconnect = false;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = (t) => debugPrint('[MQTT:$host] Subscribed: $t');

      final msg = MqttConnectMessage().withClientIdentifier(id).startClean();
      if (username.isNotEmpty) msg.authenticateAs(username, password);
      _client!.connectionMessage = msg;

      final status = await _client!.connect();
      debugPrint('[MQTT:$host] connect() → ${status?.state}');

      if (status?.state == MqttConnectionState.connected) {
        _handleConnected();
      } else {
        _setState(AppMqttState.error);
        errorMessage = 'Broker refused: ${status?.returnCode}';
        _scheduleReconnect();
      }
    } on SocketException catch (e) {
      _setState(AppMqttState.error);
      errorMessage = 'Network error: ${e.message}';
      debugPrint('[MQTT:$host] SocketException: ${e.message}');
      _scheduleReconnect();
    } on NoConnectionException catch (e) {
      _setState(AppMqttState.error);
      errorMessage = 'No connection: $e';
      _scheduleReconnect();
    } catch (e) {
      _setState(AppMqttState.error);
      errorMessage = 'Error: $e';
      debugPrint('[MQTT:$host] Error: $e');
      _scheduleReconnect();
    }
  }

  void _handleConnected() {
    if (_connectedHandled && state == AppMqttState.connected) return;
    _connectedHandled = true;
    _reconnectAttempts = 0;
    errorMessage = '';
    _reconnectTimer?.cancel();
    _setState(AppMqttState.connected);
    debugPrint('[MQTT:$host] ✅ Connected');

    for (final topic in _listeners.keys) {
      try { _client!.subscribe(topic, MqttQos.atLeastOnce); } catch (_) {}
    }
    _client!.updates?.listen(_onMessage);
  }

  void _onConnected() => _handleConnected();

  void _onDisconnected() {
    debugPrint('[MQTT:$host] Disconnected');
    _connectedHandled = false;
    if (state == AppMqttState.connected || state == AppMqttState.connecting) {
      _setState(AppMqttState.disconnected);
    }
    if (!_intentionalDisconnect) _scheduleReconnect();
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
          (msg.payload as MqttPublishMessage).payload.message);
      _topicValues[topic] = payload;
      for (final entry in _listeners.entries) {
        if (_topicMatches(entry.key, topic)) {
          for (final cb in List.from(entry.value)) {
            try { cb(payload); } catch (_) {}
          }
        }
      }
    }
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    final delay = _reconnectAttempts == 1 ? 5
        : _reconnectAttempts == 2 ? 10
        : _reconnectAttempts == 3 ? 20
        : _reconnectAttempts == 4 ? 40 : 60;
    debugPrint('[MQTT:$host] Reconnect in ${delay}s (attempt $_reconnectAttempts)');
    _setState(AppMqttState.reconnecting);
    _reconnectTimer = Timer(Duration(seconds: delay), () async {
      if (!_intentionalDisconnect && state != AppMqttState.connected) {
        await _doConnect();
      }
    });
  }

  void _setState(AppMqttState s) {
    if (state == s) return;
    state = s;
    onStateChanged();
  }

  bool _topicMatches(String filter, String topic) {
    if (filter == topic) return true;
    final fp = filter.split('/');
    final tp = topic.split('/');
    for (var i = 0; i < fp.length; i++) {
      if (fp[i] == '#') return true;
      if (i >= tp.length) return false;
      if (fp[i] != '+' && fp[i] != tp[i]) return false;
    }
    return fp.length == tp.length;
  }
}

// ── MultiMqttService — the Provider ChangeNotifier ────────────
class MultiMqttService extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────
  static final MultiMqttService _instance = MultiMqttService._internal();
  factory MultiMqttService() => _instance;
  MultiMqttService._internal();

  // Map of "host:port" → _MqttClient
  final Map<String, _MqttClient> _clients = {};

  // ── Prefs keys ─────────────────────────────────────────────
  static const _kSavedConnections = 'multi_mqtt_saved_connections';

  // ── Init — auto-connect all saved connections on app start ─
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSavedConnections) ?? [];
    for (final entry in raw) {
      // Format: "host|port|clientId|username|password"
      final parts = entry.split('|');
      if (parts.length < 2) continue;
      final host     = parts[0];
      final port     = int.tryParse(parts[1]) ?? 1883;
      final clientId = parts.length > 2 ? parts[2] : '';
      final username = parts.length > 3 ? parts[3] : '';
      final password = parts.length > 4 ? parts[4] : '';
      if (host.isNotEmpty) {
        await connectBroker(
          host: host, port: port,
          clientId: clientId, username: username, password: password,
          persist: false, // already in prefs
        );
      }
    }
  }

  // ── Connect a broker (adds to pool if not already there) ───
  Future<void> connectBroker({
    required String host,
    required int port,
    String clientId  = '',
    String username  = '',
    String password  = '',
    bool persist     = true,
  }) async {
    final key = _connKey(host, port);
    if (_clients.containsKey(key)) {
      // Already have a client — just make sure it's connecting
      await _clients[key]!.resumeIfNeeded();
      return;
    }

    final client = _MqttClient(
      host: host, port: port,
      clientId: clientId, username: username, password: password,
      onStateChanged: notifyListeners,
    );
    _clients[key] = client;
    notifyListeners();

    await client.connect();

    if (persist) await _saveAll();
  }

  // ── Disconnect a specific broker ───────────────────────────
  Future<void> disconnectBroker(String host, int port,
      {bool intentional = true}) async {
    final key = _connKey(host, port);
    final client = _clients[key];
    if (client == null) return;
    await client.disconnect(intentional: intentional);
    if (intentional) {
      _clients.remove(key);
      await _saveAll();
    }
    notifyListeners();
  }

  // ── Resume all connections (call on app resume) ────────────
  Future<void> resumeAll() async {
    for (final client in _clients.values) {
      await client.resumeIfNeeded();
    }
  }

  // ── Get state for a specific connection ────────────────────
  AppMqttState getState(String host, int port) {
    final key = _connKey(host, port);
    return _clients[key]?.state ?? AppMqttState.disconnected;
  }

  bool isConnected(String host, int port) =>
      getState(host, port) == AppMqttState.connected;

  String getError(String host, int port) =>
      _clients[_connKey(host, port)]?.errorMessage ?? '';

  // ── Publish on a specific broker ───────────────────────────
  void publish(String host, int port, String topic, String payload,
      {int qos = 0, bool retain = false}) {
    _clients[_connKey(host, port)]
        ?.publish(topic, payload, qos: qos, retain: retain);
  }

  // ── Subscribe on a specific broker ─────────────────────────
  VoidCallback subscribe(String host, int port, String topic,
      void Function(String) onMessage) {
    final key = _connKey(host, port);
    final client = _clients[key];
    if (client == null) {
      // Return a no-op unsubscribe
      return () {};
    }
    return client.subscribe(topic, onMessage);
  }

  // ── Last known value from a specific broker ────────────────
  String? lastValue(String host, int port, String topic) =>
      _clients[_connKey(host, port)]?.lastValue(topic);

  // ── Check if we have a client for this broker ──────────────
  bool hasBroker(String host, int port) =>
      _clients.containsKey(_connKey(host, port));

  // ── Get a proxy that mimics the old MqttService API ──────
  // Lets all existing live panel widgets work without any changes.
  final Map<String, MqttServiceProxy> _proxies = {};

  MqttServiceProxy getProxy(String host, int port) {
    final key = _connKey(host, port);
    return _proxies.putIfAbsent(key, () => MqttServiceProxy(this, host, port));
  }

  // ── Persist all active connections to SharedPreferences ────
  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _clients.values.map((c) =>
    '${c.host}|${c.port}|${c.clientId}|${c.username}|${c.password}'
    ).toList();
    await prefs.setStringList(_kSavedConnections, list);
  }
}