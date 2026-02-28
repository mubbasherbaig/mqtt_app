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

  bool get _useIconSwitch => widget.panel['useIconSwitch'] == true;
  Color get _onIconColor {
    final v = int.tryParse(widget.panel['onIconColor']?.toString() ?? '');
    return v != null ? Color(v) : const Color(0xFFC00000);
  }
  Color get _offIconColor {
    final v = int.tryParse(widget.panel['offIconColor']?.toString() ?? '');
    return v != null ? Color(v) : const Color(0xFF005C00);
  }
  double get _iconSize {
    switch (widget.panel['iconSize'] as String? ?? 'Small') {
      case 'Large': return 48;
      case 'Medium': return 36;
      default: return 24;
    }
  }
  String get _subTopic {
    final sub = widget.panel['subscribeTopic'] as String? ?? '';
    return sub.isNotEmpty ? sub : widget.topic;
  }

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _unsub = widget.mqtt.subscribe(_subTopic, (payload) {
      if (!mounted) return;
      setState(() => _isOn = payload == _payloadOn);
    });
  }

  @override
  void didUpdateWidget(LiveSwitchPanel old) {
    super.didUpdateWidget(old);
    if (old.panel['subscribeTopic'] != widget.panel['subscribeTopic'] ||
        old.topic != widget.topic) {
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

    if (_useIconSwitch) {
      final color = _isOn ? _onIconColor : _offIconColor;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: isConnected ? () => _toggle(!_isOn) : null,
            child: Icon(
              _isOn ? Icons.lightbulb : Icons.lightbulb_outline,
              color: isConnected ? color : Colors.grey,
              size: _iconSize,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isOn ? _payloadOn : _payloadOff,
            style: TextStyle(
              fontSize: 13,
              color: isConnected ? color : Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

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