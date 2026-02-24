import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';

class LiveBarGraphPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String dashboardPrefix;
  final MqttService mqtt;
  const LiveBarGraphPanel({super.key, required this.panel, required this.dashboardPrefix, required this.mqtt});
  @override
  State<LiveBarGraphPanel> createState() => _LiveBarGraphPanelState();
}

class _LiveBarGraphPanelState extends State<LiveBarGraphPanel> {
  final List<double> _values = [];
  final List<VoidCallback?> _unsubs = [];

  List<Map<String, dynamic>> get _bars {
    final raw = widget.panel['bars'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return [];
  }

  String _topic(String raw) {
    final disable = widget.panel['disableDashboardPrefix'] == true;
    if (disable || widget.dashboardPrefix.isEmpty) return raw;
    return '${widget.dashboardPrefix}$raw';
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _bars.length; i++) {
      _values.add(0);
      final b = _bars[i];
      final rawTopic = b['topic']?.toString() ?? '';
      if (rawTopic.isEmpty) { _unsubs.add(null); continue; }
      final factor = double.tryParse(b['factor']?.toString() ?? '1') ?? 1;
      _unsubs.add(widget.mqtt.subscribe(_topic(rawTopic), (payload) {
        final v = double.tryParse(payload);
        if (v == null || !mounted) return;
        setState(() => _values[i] = v * factor);
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
    if (_bars.isEmpty) return const Center(child: Text('No bars', style: TextStyle(color: Colors.black38)));
    final unit = widget.panel['unit'] as String? ?? '';
    final orientation = widget.panel['orientation'] as String? ?? 'Vertical';
    final maxV = _values.fold(1.0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(4),
      child: orientation == 'Horizontal'
          ? Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_bars.length, (i) {
          final b = _bars[i];
          final colorVal = int.tryParse(b['color']?.toString() ?? '');
          final color = colorVal != null ? Color(colorVal) : Colors.blue;
          final pct = maxV > 0 ? (_values[i] / maxV).clamp(0.0, 1.0) : 0.0;
          return Row(children: [
            SizedBox(width: 40, child: Text(b['label']?.toString() ?? '', style: const TextStyle(fontSize: 9), overflow: TextOverflow.ellipsis)),
            Expanded(child: FractionallySizedBox(widthFactor: pct, child: Container(height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))))),
            const SizedBox(width: 4),
            Text('${_values[i].toStringAsFixed(0)}$unit', style: const TextStyle(fontSize: 9)),
          ]);
        }),
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_bars.length, (i) {
          final b = _bars[i];
          final colorVal = int.tryParse(b['color']?.toString() ?? '');
          final color = colorVal != null ? Color(colorVal) : Colors.blue;
          final pct = maxV > 0 ? (_values[i] / maxV).clamp(0.0, 1.0) : 0.0;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('${_values[i].toStringAsFixed(0)}$unit', style: const TextStyle(fontSize: 8)),
              Flexible(child: FractionallySizedBox(heightFactor: pct.clamp(0.01, 1.0), child: Container(decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))))),
              Text(b['label']?.toString() ?? '', style: const TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis),
            ]),
          ));
        }),
      ),
    );
  }
}