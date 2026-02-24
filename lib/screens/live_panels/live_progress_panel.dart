import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/mqtt_service.dart';

class LiveProgressPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  const LiveProgressPanel({super.key, required this.panel, required this.topic, required this.mqtt});
  @override
  State<LiveProgressPanel> createState() => _LiveProgressPanelState();
}

class _LiveProgressPanelState extends State<LiveProgressPanel> {
  String _lastPayload = '';
  VoidCallback? _unsub;

  double get _min => double.tryParse(widget.panel['payloadMin']?.toString() ?? '0') ?? 0;
  double get _max => double.tryParse(widget.panel['payloadMax']?.toString() ?? '100') ?? 100;
  double get _factor => double.tryParse(widget.panel['factor']?.toString() ?? '1') ?? 1;
  int get _dec => int.tryParse(widget.panel['decimalPrecision']?.toString() ?? '0') ?? 0;
  String get _unit => widget.panel['unit'] as String? ?? '';
  String get _type => widget.panel['progressType'] as String? ?? 'Horizontal';

  Color get _color {
    final v = int.tryParse(widget.panel['color']?.toString() ?? '');
    return v != null ? Color(v) : const Color(0xFF1E88E5);
  }

  double get _value {
    final raw = double.tryParse(_lastPayload) ?? _min;
    return (raw * _factor).clamp(_min, _max);
  }

  double get _pct => _max == _min ? 0 : ((_value - _min) / (_max - _min)).clamp(0, 1);

  String get _display {
    final s = _value.toStringAsFixed(_dec);
    return _unit.isEmpty ? s : '$s $_unit';
  }

  @override
  void initState() {
    super.initState();
    _unsub = widget.mqtt.subscribe(widget.topic, (p) { if (mounted) setState(() => _lastPayload = p); });
  }

  @override
  void dispose() { _unsub?.call(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_type == 'Circular') return _buildCircular();
    if (_type == 'Vertical') return _buildVertical();
    return _buildHorizontal();
  }

  Widget _buildHorizontal() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(_display, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _color)),
      const SizedBox(height: 6),
      LinearProgressIndicator(value: _pct, backgroundColor: _color.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(_color), minHeight: 10),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$_min', style: const TextStyle(fontSize: 10, color: Colors.black45)),
        Text('$_max', style: const TextStyle(fontSize: 10, color: Colors.black45)),
      ]),
    ]);
  }

  Widget _buildVertical() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      RotatedBox(quarterTurns: 3,
        child: LinearProgressIndicator(value: _pct, backgroundColor: _color.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(_color), minHeight: 16),
      ),
      const SizedBox(width: 8),
      Text(_display, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _color)),
    ]);
  }

  Widget _buildCircular() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 70, height: 70,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(value: _pct, backgroundColor: _color.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(_color), strokeWidth: 8),
          Text(_display, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _color), textAlign: TextAlign.center),
        ]),
      ),
    ]);
  }
}