import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveMultiStateIndicatorPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  const LiveMultiStateIndicatorPanel({super.key, required this.panel, required this.topic, required this.mqtt});
  @override
  State<LiveMultiStateIndicatorPanel> createState() => _LiveMultiStateIndicatorPanelState();
}

class _LiveMultiStateIndicatorPanelState extends State<LiveMultiStateIndicatorPanel> {
  String _lastPayload = '';
  VoidCallback? _unsub;

  List<Map<String, dynamic>> get _items {
    final raw = widget.panel['items'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return [];
  }

  double get _size {
    switch (widget.panel['iconSize'] as String? ?? 'Small') {
      case 'Large': return 48;
      case 'Medium': return 34;
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
    Map<String, dynamic>? matched;
    for (final item in _items) {
      if (item['payload']?.toString() == _lastPayload) { matched = item; break; }
    }
    final colorVal = int.tryParse(matched?['color']?.toString() ?? '');
    final color = colorVal != null ? Color(colorVal) : Colors.grey;
    final stateLabel = matched?['label']?.toString() ?? (_lastPayload.isEmpty ? '—' : _lastPayload);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.radio_button_checked, size: _size, color: color),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(stateLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ),
    ]);
  }
}