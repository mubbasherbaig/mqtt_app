import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveComboBoxPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;
  const LiveComboBoxPanel({super.key, required this.panel, required this.topic, required this.mqtt, required this.qos});
  @override
  State<LiveComboBoxPanel> createState() => _LiveComboBoxPanelState();
}

class _LiveComboBoxPanelState extends State<LiveComboBoxPanel> {
  String? _selected;
  VoidCallback? _unsub;
  bool _retain = false;

  List<Map<String, dynamic>> get _items {
    final raw = widget.panel['items'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return [];
  }

  String get _subTopic {
    final sub = widget.panel['subscribeTopic'] as String?;
    return (sub != null && sub.isNotEmpty) ? sub : widget.topic;
  }

  @override
  void initState() {
    super.initState();
    _retain = widget.panel['retain'] == true;
    _unsub = widget.mqtt.subscribe(_subTopic, (payload) {
      if (!mounted) return;
      final jsonPath = widget.panel['jsonPath'] as String? ?? '';
      final extracted = extractJsonValue(payload, jsonPath);
      final match = _items.firstWhere((i) => i['payload']?.toString() == extracted, orElse: () => {});
      if (match.isNotEmpty) setState(() => _selected = extracted);
    });
  }

  @override
  void dispose() { _unsub?.call(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ok = widget.mqtt.isConnected;
    if (_items.isEmpty) return const Center(child: Text('No items', style: TextStyle(color: Colors.black38, fontSize: 12)));
    final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';

    return Center(
      child: DropdownButton<String>(
        value: _selected,
        hint: const Text('Select…', style: TextStyle(fontSize: 13)),
        isExpanded: true,
        underline: Container(height: 1, color: const Color(0xFF1E88E5)),
        items: _items.map((item) => DropdownMenuItem<String>(
          value: item['payload']?.toString() ?? '',
          child: Text(item['label']?.toString() ?? item['payload']?.toString() ?? '', style: const TextStyle(fontSize: 13)),
        )).toList(),
        onChanged: ok ? (val) {
          if (val == null) return;
          setState(() => _selected = val);
          widget.mqtt.publish(widget.topic, buildJsonPayload(val, jsonPattern), qos: widget.qos, retain: _retain);
        } : null,
      ),
    );
  }
}