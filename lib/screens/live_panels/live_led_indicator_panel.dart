import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveLedIndicatorPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  const LiveLedIndicatorPanel({super.key, required this.panel, required this.topic, required this.mqtt});
  @override
  State<LiveLedIndicatorPanel> createState() => _LiveLedIndicatorPanelState();
}

class _LiveLedIndicatorPanelState extends State<LiveLedIndicatorPanel> {
  String _lastPayload = '';
  VoidCallback? _unsub;

  String get _payloadOn  => widget.panel['payloadOn']  as String? ?? '1';
  String get _payloadOff => widget.panel['payloadOff'] as String? ?? '0';
  bool get _isOn => _lastPayload == _payloadOn;
  bool get _hasData => _lastPayload.isNotEmpty;

  Color get _onColor {
    final v = int.tryParse(widget.panel['onIconColor']?.toString() ?? '');
    return v != null ? Color(v) : const Color(0xFFDF0000);
  }
  Color get _offColor {
    final v = int.tryParse(widget.panel['offIconColor']?.toString() ?? '');
    return v != null ? Color(v) : const Color(0xFF9E9E9E);
  }
  double get _size {
    switch (widget.panel['iconSize'] as String? ?? 'Small') {
      case 'Large': return 52;
      case 'Medium': return 36;
      default: return 24;
    }
  }

  @override
  void initState() {
    super.initState();
    _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
      if (!mounted) return;
      final jsonPath = widget.panel['jsonPath'] as String? ?? '';
      final extracted = extractJsonValue(payload, jsonPath);
      setState(() => _lastPayload = extracted);
    });
  }

  @override
  void dispose() { _unsub?.call(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = _hasData ? (_isOn ? _onColor : _offColor) : Colors.grey.shade300;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: _size, height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle, color: color,
          boxShadow: _isOn ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 3)] : [],
        ),
      ),
      const SizedBox(height: 6),
      Text(_hasData ? _lastPayload : '—', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}