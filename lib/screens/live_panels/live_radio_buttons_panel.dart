import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../services/notification_service.dart';
import '../../utils/json_utils.dart';

class LiveRadioButtonsPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;

  const LiveRadioButtonsPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
    required this.qos,
  });

  @override
  State<LiveRadioButtonsPanel> createState() => _LiveRadioButtonsPanelState();
}

class _LiveRadioButtonsPanelState extends State<LiveRadioButtonsPanel> {
  String? _selected;
  VoidCallback? _unsub;
  DateTime? _lastReceivedTime;
  DateTime? _lastSentTime;

  bool get _retain => widget.panel['retain'] == true;

  bool get _showReceivedTimestamp =>
      widget.panel['showReceivedTimestamp'] == true;

  bool get _showSentTimestamp => widget.panel['showSentTimestamp'] == true;

  bool get _enableNotification => widget.panel['enableNotification'] == true;

  String get _panelName =>
      widget.panel['label'] as String? ??
      widget.panel['panelName'] as String? ??
      'Radio Buttons';

  List<Map<String, dynamic>> get _items {
    final raw = widget.panel['items'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return [];
  }

  String get _subTopic {
    final sub = widget.panel['subscribeTopic'] as String?;
    return (sub != null && sub.isNotEmpty) ? sub : widget.topic;
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _unsub = widget.mqtt.subscribe(_subTopic, (payload) {
      if (!mounted) return;
      final jsonPath = widget.panel['jsonPath'] as String? ?? '';
      final extracted = extractJsonValue(payload, jsonPath);
      if (_items.any((i) => i['payload']?.toString() == extracted)) {
        setState(() {
          _selected = extracted;
          if (_showReceivedTimestamp) _lastReceivedTime = DateTime.now();
        });
        if (_enableNotification) {
          final matched = _items.firstWhere(
            (i) => i['payload']?.toString() == extracted,
            orElse: () => {},
          );
          final label = matched['label']?.toString() ?? extracted;
          NotificationService.show(
            title: _panelName,
            body: 'Selection changed to: $label',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _unsub?.call();
    super.dispose();
  }

  void _select(String val) {
    if (!widget.mqtt.isConnected) return;
    final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
    setState(() {
      _selected = val;
      if (_showSentTimestamp) _lastSentTime = DateTime.now();
    });
    widget.mqtt.publish(
      widget.topic,
      buildJsonPayload(val, jsonPattern),
      qos: widget.qos,
      retain: _retain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.mqtt.isConnected;
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'No items',
          style: TextStyle(color: Colors.black38, fontSize: 12),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView(
            children: _items.map((item) {
              final payload = item['payload']?.toString() ?? '';
              final label = item['label']?.toString() ?? payload;
              return InkWell(
                onTap: ok ? () => _select(payload) : null,
                child: Row(
                  children: [
                    Radio<String>(
                      value: payload,
                      groupValue: _selected,
                      activeColor: const Color(0xFF1E88E5),
                      onChanged: ok
                          ? (v) {
                              if (v != null) _select(v);
                            }
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: ok ? Colors.black87 : Colors.black38,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        if (_showSentTimestamp && _lastSentTime != null) ...[
          const SizedBox(height: 2),
          Text(
            '↑ ${_formatTime(_lastSentTime!)}',
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
        ],
        if (_showReceivedTimestamp && _lastReceivedTime != null) ...[
          const SizedBox(height: 2),
          Text(
            '↓ ${_formatTime(_lastReceivedTime!)}',
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
        ],
      ],
    );
  }
}
