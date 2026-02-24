import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/mqtt_service.dart';

class LiveChartPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String dashboardPrefix;
  final MqttService mqtt;
  const LiveChartPanel({super.key, required this.panel, required this.dashboardPrefix, required this.mqtt});
  @override
  State<LiveChartPanel> createState() => _LiveChartPanelState();
}

class _LiveChartPanelState extends State<LiveChartPanel> {
  final List<double> _values = [];
  final List<VoidCallback?> _unsubs = [];

  List<Map<String, dynamic>> get _items {
    final raw = widget.panel['items'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return [];
  }

  String get _chartType => widget.panel['chartType'] as String? ?? 'Pie Chart';

  String _topic(String raw) {
    final disable = widget.panel['disableDashboardPrefix'] == true;
    if (disable || widget.dashboardPrefix.isEmpty) return raw;
    return '${widget.dashboardPrefix}$raw';
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _items.length; i++) {
      _values.add(0);
      final item = _items[i];
      final rawTopic = item['topic']?.toString() ?? '';
      if (rawTopic.isEmpty) { _unsubs.add(null); continue; }
      final factor = double.tryParse(item['factor']?.toString() ?? '1') ?? 1;
      _unsubs.add(widget.mqtt.subscribe(_topic(rawTopic), (payload) {
        final v = double.tryParse(payload);
        if (v == null || !mounted) return;
        setState(() => _values[i] = (v * factor).abs());
      }));
    }
  }

  @override
  void dispose() {
    for (final u in _unsubs) u?.call();
    super.dispose();
  }

  List<Color> get _colors => _items.map((item) {
    final v = int.tryParse(item['color']?.toString() ?? '');
    return v != null ? Color(v) : Colors.blue;
  }).toList();

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const Center(child: Text('No items', style: TextStyle(color: Colors.black38)));
    return CustomPaint(
      painter: _ChartPainter(_values, _colors, _chartType),
      child: Container(),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final String type;
  _ChartPainter(this.values, this.colors, this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.42;

    if (type == 'Donut Chart') {
      double start = -math.pi / 2;
      for (int i = 0; i < values.length; i++) {
        final sweep = (values[i] / total) * 2 * math.pi;
        canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, sweep, false,
            Paint()..color = colors[i % colors.length]..style = PaintingStyle.stroke..strokeWidth = r * 0.4);
        start += sweep;
      }
    } else {
      // Pie
      double start = -math.pi / 2;
      for (int i = 0; i < values.length; i++) {
        final sweep = (values[i] / total) * 2 * math.pi;
        canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, sweep, true,
            Paint()..color = colors[i % colors.length]..style = PaintingStyle.fill);
        canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, sweep, true,
            Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
        start += sweep;
      }
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => true;
}