// lib/services/mqtt_service_proxy.dart
//
// Extends MqttService (abstract base) so it can be passed directly
// to any live panel widget without type errors.

import 'package:flutter/foundation.dart';
import 'mqtt_service.dart';
import 'multi_mqtt_service.dart';

class MqttServiceProxy extends MqttService {
  final MultiMqttService _multi;
  final String _host;
  final int    _port;

  MqttServiceProxy(this._multi, this._host, this._port) {
    _multi.addListener(_forward);
  }

  void _forward() => notifyListeners();

  @override
  void dispose() {
    _multi.removeListener(_forward);
    super.dispose();
  }

  @override
  AppMqttState get connectionState => _multi.getState(_host, _port);

  @override
  String get errorMessage => _multi.getError(_host, _port);

  @override
  String get host => _host;

  @override
  int get port => _port;

  @override
  String? lastValue(String topic) => _multi.lastValue(_host, _port, topic);

  @override
  void publish(String topic, String payload,
      {int qos = 0, bool retain = false}) {
    _multi.publish(_host, _port, topic, payload, qos: qos, retain: retain);
  }

  @override
  VoidCallback subscribe(String topic, void Function(String) onMessage) {
    return _multi.subscribe(_host, _port, topic, onMessage);
  }
}