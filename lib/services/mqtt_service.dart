import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// Our connection state enum — named AppMqttState to avoid collision
// with mqtt_client's own MqttConnectionState enum.
enum AppMqttState {
  disconnected,
  connecting,
  connected,
  error,
}

class MqttService extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  // ── State ──────────────────────────────────────────────────
  MqttServerClient? _client;
  AppMqttState _state = AppMqttState.disconnected;
  String _errorMessage = '';

  String _host = '';
  int _port = 1883;
  String _clientId = '';
  String _username = '';
  String _password = '';

  final Map<String, List<void Function(String payload)>> _listeners = {};
  final Map<String, String> _topicValues = {};

  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;

  // ── Public getters ─────────────────────────────────────────
  AppMqttState get connectionState => _state;
  bool get isConnected => _state == AppMqttState.connected;
  String get errorMessage => _errorMessage;
  String get host => _host;
  int get port => _port;
  String? lastValue(String topic) => _topicValues[topic];

  // ── Connect ────────────────────────────────────────────────
  Future<void> connect({
    required String host,
    required int port,
    String clientId = '',
    String username = '',
    String password = '',
  }) async {
    if (_state == AppMqttState.connected && _host == host && _port == port) {
      return;
    }
    await disconnect(intentional: false);

    _host = host;
    _port = port;
    _clientId = clientId.isEmpty
        ? 'mqttpanel_${DateTime.now().millisecondsSinceEpoch}'
        : clientId;
    _username = username;
    _password = password;
    _intentionalDisconnect = false;

    await _doConnect();
  }

  Future<void> _doConnect() async {
    _setState(AppMqttState.connecting);

    try {
      _client = MqttServerClient.withPort(_host, _clientId, _port);

      // Enable logging in debug mode so we can see what's happening
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = 20;
      _client!.connectTimeoutPeriod = 8000;
      _client!.autoReconnect = false;

      // Set callbacks BEFORE connecting
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;

      // Build a clean connect message — NO withWillQos unless we also
      // provide a will topic/message, otherwise some brokers reject it.
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .startClean();

      if (_username.isNotEmpty) {
        connMessage.authenticateAs(_username, _password);
      }
      _client!.connectionMessage = connMessage;

      // connect() returns the connection status.
      // Do NOT rely solely on the onConnected callback — check the return value.
      final status = await _client!.connect();

      debugPrint('[MQTT] connect() returned: ${status?.state} / ${status?.returnCode}');

      if (status?.state == MqttConnectionState.connected) {
        // Successfully connected — _onConnected may or may not have fired yet,
        // so we call it manually to be safe.
        _handleConnected();
      } else {
        final code = status?.returnCode;
        _setState(AppMqttState.error);
        _errorMessage = 'Broker refused: $code';
        debugPrint('[MQTT] Connection refused: $code');
        _scheduleReconnect();
      }
    } on SocketException catch (e) {
      _setState(AppMqttState.error);
      _errorMessage = 'Network error: ${e.message}';
      debugPrint('[MQTT] SocketException: ${e.message}');
      _scheduleReconnect();
    } on NoConnectionException catch (e) {
      _setState(AppMqttState.error);
      _errorMessage = 'No connection: $e';
      debugPrint('[MQTT] NoConnectionException: $e');
      _scheduleReconnect();
    } catch (e) {
      _setState(AppMqttState.error);
      _errorMessage = 'Error: $e';
      debugPrint('[MQTT] Unknown error: $e');
      _scheduleReconnect();
    }
  }

  // ── Disconnect ─────────────────────────────────────────────
  Future<void> disconnect({bool intentional = true}) async {
    _intentionalDisconnect = intentional;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    try {
      _client?.disconnect();
    } catch (_) {}
    _client = null;
    _setState(AppMqttState.disconnected);
    _listeners.clear();
    _topicValues.clear();
  }

  // ── Publish ────────────────────────────────────────────────
  void publish(String topic, String payload,
      {int qos = 0, bool retain = false}) {
    if (_client == null || !isConnected) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    final mqttQos = qos == 1
        ? MqttQos.atLeastOnce
        : qos == 2
        ? MqttQos.exactlyOnce
        : MqttQos.atMostOnce;
    try {
      _client!.publishMessage(topic, mqttQos, builder.payload!, retain: retain);
    } catch (e) {
      debugPrint('[MQTT] Publish error: $e');
    }
  }

  // ── Subscribe ──────────────────────────────────────────────
  VoidCallback subscribe(
      String topic, void Function(String payload) onMessage) {
    if (!_listeners.containsKey(topic)) {
      _listeners[topic] = [];
      if (isConnected) {
        _client!.subscribe(topic, MqttQos.atLeastOnce);
      }
    }
    _listeners[topic]!.add(onMessage);

    // Deliver last known value immediately if available
    if (_topicValues.containsKey(topic)) {
      Future.microtask(() => onMessage(_topicValues[topic]!));
    }

    return () {
      _listeners[topic]?.remove(onMessage);
      if (_listeners[topic]?.isEmpty ?? false) {
        _listeners.remove(topic);
        if (isConnected) {
          try { _client!.unsubscribe(topic); } catch (_) {}
        }
      }
    };
  }

  // ── Internal connection handler ────────────────────────────
  // Called from both _onConnected callback AND directly after connect() returns.
  // Guard with a flag so it only runs once per connection.
  bool _connectedHandled = false;

  void _handleConnected() {
    if (_connectedHandled && _state == AppMqttState.connected) return;
    _connectedHandled = true;

    _setState(AppMqttState.connected);
    _errorMessage = '';
    _reconnectTimer?.cancel();
    debugPrint('[MQTT] Connected to $_host:$_port');

    // Re-subscribe to all active topics
    for (final topic in _listeners.keys) {
      try {
        _client!.subscribe(topic, MqttQos.atLeastOnce);
      } catch (_) {}
    }

    // Start listening to incoming messages
    _client!.updates?.listen(_onMessageReceived);
  }

  // ── Callbacks ──────────────────────────────────────────────
  void _onConnected() {
    debugPrint('[MQTT] _onConnected callback fired');
    _handleConnected();
  }

  void _onDisconnected() {
    debugPrint('[MQTT] Disconnected');
    _connectedHandled = false;
    if (_state == AppMqttState.connected) {
      _setState(AppMqttState.disconnected);
    }
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _onSubscribed(String topic) {
    debugPrint('[MQTT] Subscribed: $topic');
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      final recMsg = msg.payload as MqttPublishMessage;
      final payload =
      MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);

      debugPrint('[MQTT] Message on $topic: $payload');
      _topicValues[topic] = payload;

      for (final entry in _listeners.entries) {
        if (_topicMatches(entry.key, topic)) {
          for (final callback in List.from(entry.value)) {
            try { callback(payload); } catch (_) {}
          }
        }
      }
    }
  }

  // ── Auto-reconnect ─────────────────────────────────────────
  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    _reconnectTimer?.cancel();
    debugPrint('[MQTT] Scheduling reconnect in 5s...');
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      if (!_intentionalDisconnect && _state != AppMqttState.connected) {
        _connectedHandled = false;
        await _doConnect();
      }
    });
  }

  // ── Helpers ────────────────────────────────────────────────
  void _setState(AppMqttState state) {
    if (_state == state) return; // avoid redundant rebuilds
    _state = state;
    notifyListeners();
  }

  bool _topicMatches(String filter, String topic) {
    if (filter == topic) return true;
    final filterParts = filter.split('/');
    final topicParts = topic.split('/');
    for (var i = 0; i < filterParts.length; i++) {
      if (filterParts[i] == '#') return true;
      if (i >= topicParts.length) return false;
      if (filterParts[i] != '+' && filterParts[i] != topicParts[i]) {
        return false;
      }
    }
    return filterParts.length == topicParts.length;
  }
}