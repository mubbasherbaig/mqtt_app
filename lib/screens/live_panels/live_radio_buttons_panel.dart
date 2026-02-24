import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';

class LiveRadioButtonsPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;
  const LiveRadioButtonsPanel({super.key, required this.panel, required this.topic, required this.mqtt, required this.qos});
  @override
  State<LiveRadioButtonsPanel> createState() => _LiveRadioButtonsPanelState();
}

class _LiveRadioButtonsPanelState extends State<LiveRadioButtonsPanel> {
  String? _selected;
  VoidCallback? _unsub;

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
    _unsub = widget.mqtt.subscribe(_subTopic, (payload) {
      if (!mounted) return;
      if (_items.any((i) => i['payload']?.toString() == payload)) {
        setState(() => _selected = payload);
      }
    });
  }

  @override
  void dispose() { _unsub?.call(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ok = widget.mqtt.isConnected;
    if (_items.isEmpty) return const Center(child: Text('No items', style: TextStyle(color: Colors.black38, fontSize: 12)));
    final retain = widget.panel['retain'] == true;
    return ListView(
      children: _items.map((item) {
        final payload = item['payload']?.toString() ?? '';
        return InkWell(
          onTap: ok ? () {
            setState(() => _selected = payload);
            widget.mqtt.publish(widget.topic, payload, qos: widget.qos, retain: retain);
          } : null,
          child: Row(children: [
            Radio<String>(
              value: payload, groupValue: _selected,
              activeColor: const Color(0xFF1E88E5),
              onChanged: ok ? (v) {
                if (v == null) return;
                setState(() => _selected = v);
                widget.mqtt.publish(widget.topic, v, qos: widget.qos, retain: retain);
              } : null,
            ),
            Expanded(child: Text(item['label']?.toString() ?? payload, style: TextStyle(fontSize: 13, color: ok ? Colors.black87 : Colors.black38))),
          ]),
        );
      }).toList(),
    );
  }
}