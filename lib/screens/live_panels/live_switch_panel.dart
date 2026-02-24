import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';

class LiveSwitchPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;

  const LiveSwitchPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
    required this.qos,
  });

  @override
  State<LiveSwitchPanel> createState() => _LiveSwitchPanelState();
}

class _LiveSwitchPanelState extends State<LiveSwitchPanel> {
  bool _isOn = false;
  VoidCallback? _unsub;

  String get _payloadOn => widget.panel['payloadOn'] as String? ?? 'ON';
  String get _payloadOff => widget.panel['payloadOff'] as String? ?? 'OFF';
  bool get _retain => widget.panel['retain'] == true;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
      if (!mounted) return;
      setState(() => _isOn = payload == _payloadOn);
    });
  }

  @override
  void didUpdateWidget(LiveSwitchPanel old) {
    super.didUpdateWidget(old);
    if (old.topic != widget.topic) {
      _unsub?.call();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsub?.call();
    super.dispose();
  }

  void _toggle(bool value) {
    if (!widget.mqtt.isConnected) return;
    final payload = value ? _payloadOn : _payloadOff;
    widget.mqtt.publish(widget.topic, payload,
        qos: widget.qos, retain: _retain);
    setState(() => _isOn = value);
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.mqtt.isConnected;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Switch(
          value: _isOn,
          onChanged: isConnected ? _toggle : null,
          activeColor: const Color(0xFF1E88E5),
        ),
        const SizedBox(height: 4),
        Text(
          _isOn ? _payloadOn : _payloadOff,
          style: TextStyle(
            fontSize: 13,
            color: _isOn ? const Color(0xFF1E88E5) : Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}