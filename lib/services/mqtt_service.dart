// lib/services/mqtt_service.dart
//
// MqttService is now an abstract base class.
// - MqttServiceImpl  (in this file)  = the real MQTT connection
// - MqttServiceProxy (mqtt_service_proxy.dart) = thin adapter for MultiMqttService
//
// All 22 live panel files are UNCHANGED — they still declare
// `final MqttService mqtt` and everything works via polymorphism.

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// ── State enum ─────────────────────────────────────────────────
enum AppMqttState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

// ─────────────────────────────────────────────────────────────
// ABSTRACT BASE — defines the interface every live panel uses
// ─────────────────────────────────────────────────────────────
abstract class MqttService extends ChangeNotifier {
  AppMqttState get connectionState;
  bool         get isConnected => connectionState == AppMqttState.connected;
  String       get errorMessage;
  String       get host;
  int          get port;

  String? lastValue(String topic);

  void publish(String topic, String payload,
      {int qos = 0, bool retain = false});

  VoidCallback subscribe(String topic, void Function(String) onMessage);
}

// ─────────────────────────────────────────────────────────────
// REAL IMPLEMENTATION — single-broker MQTT client
// Used by the app when NOT using MultiMqttService.
// (Kept for backward compat; MultiMqttService uses _MqttClient internally.)
// ─────────────────────────────────────────────────────────────
class MqttServiceImpl extends MqttService {
  // Singleton
  static final MqttServiceImpl _instance = MqttServiceImpl._internal();
  factory MqttServiceImpl() => _instance;
  MqttServiceImpl._internal();

  MqttServerClient? _client;
  AppMqttState      _state        = AppMqttState.disconnected;
  String            _errorMessage = '';
  String            _host         = '';
  int               _port         = 1883;
  String            _clientId     = '';
  String            _username     = '';
  String            _password     = '';

  final Map<String, List<void Function(String)>> _listeners  = {};
  final Map<String, String>                      _topicValues = {};

  Timer? _reconnectTimer;
  bool   _intentionalDisconnect = false;
  int    _reconnectAttempts     = 0;
  bool   _connectedHandled      = false;

  @override AppMqttState get connectionState => _state;
  @override String get errorMessage => _errorMessage;
  @override String get host => _host;
  @override int    get port => _port;
  @override String? lastValue(String topic) => _topicValues[topic];

  Future<void> connect({
    required String host,
    required int    port,
    String clientId = '',
    String username = '',
    String password = '',
  }) async {
    if (_state == AppMqttState.connected && _host == host && _port == port) return;
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    await _disconnectClean();
    _host     = host;
    _port     = port;
    _clientId = clientId.isEmpty
        ? 'mqttpanel_${DateTime.now().millisecondsSinceEpoch}'
        : clientId;
    _username = username;
    _password = password;
    _intentionalDisconnect = false;
    await _doConnect();
  }

  Future<void> disconnect({bool intentional = true}) async {
    _intentionalDisconnect = intentional;
    _reconnectTimer?.cancel();
    await _disconnectClean();
    if (intentional) {
      _host = '';
      _listeners.clear();
      _topicValues.clear();
    }
    _setState(AppMqttState.disconnected);
  }

  Future<void> resumeIfNeeded() async {
    if (_intentionalDisconnect || _host.isEmpty) return;
    if (_state == AppMqttState.connected || _state == AppMqttState.connecting) return;
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    await _doConnect();
  }

  @override
  void publish(String topic, String payload,
      {int qos = 0, bool retain = false}) {
    if (_client == null || !isConnected) return;
    final builder = MqttClientPayloadBuilder()..addString(payload);
    final mqttQos = qos == 1 ? MqttQos.atLeastOnce
        : qos == 2 ? MqttQos.exactlyOnce
        : MqttQos.atMostOnce;
    try {
      _client!.publishMessage(topic, mqttQos, builder.payload!, retain: retain);
    } catch (e) {
      debugPrint('[MQTT] Publish error: $e');
    }
  }

  @override
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

  Future<void> _disconnectClean() async {
    try { _client?.disconnect(); } catch (_) {}
    _client = null;
  }

  Future<void> _doConnect() async {
    _connectedHandled = false;
    _setState(AppMqttState.connecting);
    try {
      final id = _clientId.isEmpty
          ? 'mqttpanel_${DateTime.now().millisecondsSinceEpoch}'
          : _clientId;
      _client = MqttServerClient.withPort(_host, id, _port);
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod      = 20;
      _client!.connectTimeoutPeriod = 8000;
      _client!.autoReconnect        = false;
      _client!.onDisconnected       = _onDisconnected;
      _client!.onConnected          = _onConnected;
      _client!.onSubscribed         = (t) {};
      final msg = MqttConnectMessage().withClientIdentifier(id).startClean();
      if (_username.isNotEmpty) msg.authenticateAs(_username, _password);
      _client!.connectionMessage = msg;
      final status = await _client!.connect();
      if (status?.state == MqttConnectionState.connected) {
        _handleConnected();
      } else {
        _setState(AppMqttState.error);
        _errorMessage = 'Refused: ${status?.returnCode}';
        _scheduleReconnect();
      }
    } on SocketException catch (e) {
      _setState(AppMqttState.error);
      _errorMessage = 'Network error: ${e.message}';
      _scheduleReconnect();
    } catch (e) {
      _setState(AppMqttState.error);
      _errorMessage = 'Error: $e';
      _scheduleReconnect();
    }
  }

  void _handleConnected() {
    if (_connectedHandled && _state == AppMqttState.connected) return;
    _connectedHandled = true;
    _reconnectAttempts = 0;
    _errorMessage = '';
    _reconnectTimer?.cancel();
    _setState(AppMqttState.connected);
    for (final t in _listeners.keys) {
      try { _client!.subscribe(t, MqttQos.atLeastOnce); } catch (_) {}
    }
    _client!.updates?.listen(_onMsg);
  }

  void _onConnected()    => _handleConnected();

  void _onDisconnected() {
    _connectedHandled = false;
    if (_state == AppMqttState.connected || _state == AppMqttState.connecting) {
      _setState(AppMqttState.disconnected);
    }
    if (!_intentionalDisconnect) _scheduleReconnect();
  }

  void _onMsg(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final topic   = msg.topic;
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
    _setState(AppMqttState.reconnecting);
    _reconnectTimer = Timer(Duration(seconds: delay), () async {
      if (!_intentionalDisconnect && _state != AppMqttState.connected) {
        await _doConnect();
      }
    });
  }

  void _setState(AppMqttState s) {
    if (_state == s) return;
    _state = s;
    notifyListeners();
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