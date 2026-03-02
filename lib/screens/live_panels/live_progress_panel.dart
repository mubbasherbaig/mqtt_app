import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../services/notification_service.dart';
import '../../utils/json_utils.dart';

class LiveProgressPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  const LiveProgressPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
  });
  @override
  State<LiveProgressPanel> createState() => _LiveProgressPanelState();
}

class _LiveProgressPanelState extends State<LiveProgressPanel> {
  String _lastPayload = '';
  VoidCallback? _unsub;
  DateTime? _lastReceivedTime;

  double get _min =>
      double.tryParse(widget.panel['payloadMin']?.toString() ?? '0') ?? 0;
  double get _max =>
      double.tryParse(widget.panel['payloadMax']?.toString() ?? '100') ?? 100;
  double get _factor =>
      double.tryParse(widget.panel['factor']?.toString() ?? '1') ?? 1;
  int get _dec =>
      int.tryParse(widget.panel['decimalPrecision']?.toString() ?? '0') ?? 0;
  String get _unit => widget.panel['unit'] as String? ?? '';
  String get _type => widget.panel['progressType'] as String? ?? 'Horizontal';
  bool get _dynamicColor => widget.panel['dynamicColor'] == true;
  bool get _showReceivedTimestamp =>
      widget.panel['showReceivedTimestamp'] == true;

  bool get _enableNotification => widget.panel['enableNotification'] == true;

  String get _panelName =>
      widget.panel['label'] as String? ??
          widget.panel['panelName'] as String? ??
          'Progress';

  double get _value {
    final raw = double.tryParse(_lastPayload) ?? _min;
    return (raw * _factor).clamp(_min, _max);
  }

  double get _pct =>
      _max == _min ? 0 : ((_value - _min) / (_max - _min)).clamp(0.0, 1.0);

  String get _display {
    final s = _value.toStringAsFixed(_dec);
    return _unit.isEmpty ? s : '$s $_unit';
  }

  // Base color from config; dynamicColor overrides with green→yellow→red gradient
  Color get _baseColor {
    final v = int.tryParse(widget.panel['color']?.toString() ?? '');
    return v != null ? Color(v) : const Color(0xFF1E88E5);
  }

  Color get _color {
    if (_dynamicColor) {
      if (_pct < 0.5) {
        return Color.lerp(Colors.green, Colors.yellow, _pct * 2)!;
      } else {
        return Color.lerp(Colors.yellow, Colors.red, (_pct - 0.5) * 2)!;
      }
    }
    return _baseColor;
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
      if (!mounted) return;
      final jsonPath = widget.panel['jsonPath'] as String? ?? '';
      final extracted = extractJsonValue(payload, jsonPath);
      setState(() {
        _lastPayload = extracted;
        if (_showReceivedTimestamp) _lastReceivedTime = DateTime.now();
      });
      if (_enableNotification) {
        NotificationService.show(
          title: _panelName,
          body: '$_display received on ${widget.topic}',
        );
      }
    });
  }

  @override
  void dispose() {
    _unsub?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_type == 'Circular') {
      body = _buildCircular();
    } else if (_type == 'Vertical') {
      body = _buildVertical();
    } else {
      body = _buildHorizontal();
    }

    if (!_showReceivedTimestamp || _lastReceivedTime == null) return body;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        body,
        const SizedBox(height: 4),
        Text(
          '↓ ${_formatTime(_lastReceivedTime!)}',
          style: const TextStyle(fontSize: 10, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _buildHorizontal() {
    final c = _color;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        _display,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c),
      ),
      const SizedBox(height: 6),
      LinearProgressIndicator(
        value: _pct,
        backgroundColor: c.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation(c),
        minHeight: 10,
      ),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$_min', style: const TextStyle(fontSize: 10, color: Colors.black45)),
        Text('$_max', style: const TextStyle(fontSize: 10, color: Colors.black45)),
      ]),
    ]);
  }

  Widget _buildVertical() {
    final c = _color;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      RotatedBox(
        quarterTurns: 3,
        child: LinearProgressIndicator(
          value: _pct,
          backgroundColor: c.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation(c),
          minHeight: 16,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        _display,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c),
      ),
    ]);
  }

  Widget _buildCircular() {
    final c = _color;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 70,
        height: 70,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(
            value: _pct,
            backgroundColor: c.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(c),
            strokeWidth: 8,
          ),
          Text(
            _display,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    ]);
  }
}