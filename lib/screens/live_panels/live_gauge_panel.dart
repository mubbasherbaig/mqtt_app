import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/mqtt_service.dart';
import '../../services/notification_service.dart';
import '../../utils/json_utils.dart';

class LiveGaugePanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  const LiveGaugePanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
  });
  @override
  State<LiveGaugePanel> createState() => _LiveGaugePanelState();
}

class _LiveGaugePanelState extends State<LiveGaugePanel> {
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
  bool get _showReceivedTimestamp =>
      widget.panel['showReceivedTimestamp'] == true;

  bool get _enableNotification => widget.panel['enableNotification'] == true;

  String get _panelName =>
      widget.panel['label'] as String? ??
          widget.panel['panelName'] as String? ??
          'Gauge';

  Color _c(String key, Color fallback) {
    final v = int.tryParse(widget.panel[key]?.toString() ?? '');
    return v != null ? Color(v) : fallback;
  }

  double get _value =>
      ((double.tryParse(_lastPayload) ?? _min) * _factor).clamp(_min, _max);
  double get _pct =>
      _max == _min ? 0 : ((_value - _min) / (_max - _min)).clamp(0.0, 1.0);

  Color get _arcColor {
    if (_pct < 0.33) return _c('arcColor1', Colors.green);
    if (_pct < 0.66) return _c('arcColor2', Colors.yellow);
    return _c('arcColor3', Colors.orange);
  }

  String get _display {
    final s = _value.toStringAsFixed(_dec);
    return _unit.isEmpty ? s : '$s $_unit';
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
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 90,
        height: 55,
        child: CustomPaint(
          painter: _GaugePainter(
            _pct,
            _c('arcColor1', Colors.green),
            _c('arcColor2', Colors.yellow),
            _c('arcColor3', Colors.orange),
            _arcColor,
          ),
        ),
      ),
      Text(
        _display,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _arcColor),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${_min.toStringAsFixed(_dec)}',
            style: const TextStyle(fontSize: 9, color: Colors.black45)),
        Text('${_max.toStringAsFixed(_dec)}',
            style: const TextStyle(fontSize: 9, color: Colors.black45)),
      ]),
      if (_showReceivedTimestamp && _lastReceivedTime != null) ...[
        const SizedBox(height: 2),
        Text(
          '↓ ${_formatTime(_lastReceivedTime!)}',
          style: const TextStyle(fontSize: 10, color: Colors.black45),
        ),
      ],
    ]);
  }
}

class _GaugePainter extends CustomPainter {
  final double pct;
  final Color c1, c2, c3, needle;
  _GaugePainter(this.pct, this.c1, this.c2, this.c3, this.needle);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.9;
    final r = size.width * 0.45;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      paint.color = [c1, c2, c3][i].withValues(alpha: 0.3);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        math.pi + (i * math.pi / 3),
        math.pi / 3,
        false,
        paint,
      );
    }
    paint.color = needle;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi,
      math.pi * pct,
      false,
      paint,
    );

    final angle = math.pi + math.pi * pct;
    final nx = cx + (r * 0.75) * math.cos(angle);
    final ny = cy + (r * 0.75) * math.sin(angle);
    canvas.drawLine(
      Offset(cx, cy),
      Offset(nx, ny),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = Colors.black54);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.pct != pct;
}