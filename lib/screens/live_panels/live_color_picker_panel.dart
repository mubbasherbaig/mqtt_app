import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveColorPickerPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;

  const LiveColorPickerPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
    required this.qos,
  });

  @override
  State<LiveColorPickerPanel> createState() => _LiveColorPickerPanelState();
}

class _LiveColorPickerPanelState extends State<LiveColorPickerPanel> {
  Color _color = Colors.blue;
  VoidCallback? _unsub;
  DateTime? _lastReceivedTime;
  DateTime? _lastSentTime;

  bool get _addAlpha => widget.panel['addAlpha'] == true;
  bool get _hideValue => widget.panel['hideColorValue'] == true;
  bool get _retain => widget.panel['retain'] == true;
  bool get _showReceivedTimestamp => widget.panel['showReceivedTimestamp'] == true;
  bool get _showSentTimestamp => widget.panel['showSentTimestamp'] == true;

  String get _subTopic {
    final sub = widget.panel['subscribeTopic'] as String?;
    return (sub != null && sub.isNotEmpty) ? sub : widget.topic;
  }

  Color _parseHexColor(String hex) {
    final clean = hex.replaceAll('#', '').replaceAll('0x', '');
    if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
    if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    return Colors.blue;
  }

  String _colorToHex(Color c) {
    if (_addAlpha) {
      return '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    return '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
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
      try {
        setState(() {
          _color = _parseHexColor(extracted);
          if (_showReceivedTimestamp) _lastReceivedTime = DateTime.now();
        });
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _unsub?.call();
    super.dispose();
  }

  void _showPicker() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.teal,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.brown,
      Colors.grey,
      Colors.black,
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) => GestureDetector(
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _color = c;
                if (_showSentTimestamp) _lastSentTime = DateTime.now();
              });
              if (widget.mqtt.isConnected) {
                final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
                final toSend = buildJsonPayload(_colorToHex(c), jsonPattern);
                widget.mqtt.publish(widget.topic, toSend, qos: widget.qos, retain: _retain);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _color == c ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.mqtt.isConnected;
    final hex = _colorToHex(_color);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: ok ? _showPicker : null,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 2),
              boxShadow: [
                BoxShadow(color: _color.withValues(alpha: 0.4), blurRadius: 8),
              ],
            ),
            child: ok ? const Icon(Icons.colorize, color: Colors.white, size: 22) : null,
          ),
        ),
        if (!_hideValue) ...[
          const SizedBox(height: 6),
          Text(
            hex,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.black54),
          ),
        ],
        if (_showSentTimestamp && _lastSentTime != null) ...[
          const SizedBox(height: 4),
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