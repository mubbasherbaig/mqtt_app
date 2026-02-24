import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/mqtt_service.dart';

class LiveLineGraphPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String dashboardPrefix;
  final MqttService mqtt;
  const LiveLineGraphPanel({super.key, required this.panel, required this.dashboardPrefix, required this.mqtt});
  @override
  State<LiveLineGraphPanel> createState() => _LiveLineGraphPanelState();
}

class _LiveLineGraphPanelState extends State<LiveLineGraphPanel> {
  // Each series: list of (time, value) points
  final List<List<double>> _seriesData = [];
  final List<VoidCallback?> _unsubs = [];

  List<Map<String, dynamic>> get _graphs {
    final raw = widget.panel['graphs'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return [];
  }

  int get _maxPoints => int.tryParse(widget.panel['maxPersistence']?.toString() ?? '10') ?? 10;

  String _topic(String raw) {
    final disable = widget.panel['disableDashboardPrefix'] == true;
    if (disable || widget.dashboardPrefix.isEmpty) return raw;
    return '${widget.dashboardPrefix}$raw';
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _graphs.length; i++) {
      _seriesData.add([]);
      final g = _graphs[i];
      final rawTopic = g['topic']?.toString() ?? '';
      if (rawTopic.isEmpty) { _unsubs.add(null); continue; }
      final topic = _topic(rawTopic);
      final factor = double.tryParse(g['factor']?.toString() ?? '1') ?? 1;
      _unsubs.add(widget.mqtt.subscribe(topic, (payload) {
        final v = double.tryParse(payload);
        if (v == null || !mounted) return;
        setState(() {
          _seriesData[i].add(v * factor);
          if (_seriesData[i].length > _maxPoints) _seriesData[i].removeAt(0);
        });
      }));
    }
  }

  @override
  void dispose() {
    for (final u in _unsubs) u?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_graphs.isEmpty) return const Center(child: Text('No series', style: TextStyle(color: Colors.black38)));
    return CustomPaint(
      painter: _LinePainter(_seriesData, _graphs),
      child: Container(),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<List<double>> data;
  final List<Map<String, dynamic>> graphs;
  _LinePainter(this.data, this.graphs);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw axes
    final axisPaint = Paint()..color = Colors.black26..strokeWidth = 1;
    canvas.drawLine(Offset(24, 4), Offset(24, size.height - 16), axisPaint);
    canvas.drawLine(Offset(24, size.height - 16), Offset(size.width - 4, size.height - 16), axisPaint);

    for (int s = 0; s < data.length && s < graphs.length; s++) {
      final pts = data[s];
      if (pts.length < 2) continue;
      final colorVal = int.tryParse(graphs[s]['color']?.toString() ?? '');
      final color = colorVal != null ? Color(colorVal) : Colors.blue;
      final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

      double minV = pts.reduce(math.min);
      double maxV = pts.reduce(math.max);
      if (maxV == minV) { maxV = minV + 1; }

      final w = size.width - 28;
      final h = size.height - 20;
      final path = Path();
      for (int i = 0; i < pts.length; i++) {
        final x = 24 + (i / (pts.length - 1)) * w;
        final y = 4 + h - ((pts[i] - minV) / (maxV - minV)) * h;
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}