
import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';

class LiveColorPickerPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;
  const LiveColorPickerPanel({super.key, required this.panel, required this.topic, required this.mqtt, required this.qos});
  @override
  State<LiveColorPickerPanel> createState() => _LiveColorPickerPanelState();
}

class _LiveColorPickerPanelState extends State<LiveColorPickerPanel> {
  Color _color = Colors.blue;
  VoidCallback? _unsub;

  bool get _addAlpha => widget.panel['addAlpha'] == true;
  bool get _hideValue => widget.panel['hideColorValue'] == true;
  bool get _retain => widget.panel['retain'] == true;

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

  @override
  void initState() {
    super.initState();
    _unsub = widget.mqtt.subscribe(_subTopic, (payload) {
      if (!mounted) return;
      try { setState(() => _color = _parseHexColor(payload)); } catch (_) {}
    });
  }

  @override
  void dispose() { _unsub?.call(); super.dispose(); }

  String _colorToHex(Color c) {
    if (_addAlpha) return '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    return '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void _showPicker() {
    final colors = [Colors.red, Colors.pink, Colors.orange, Colors.yellow, Colors.green, Colors.teal, Colors.blue, Colors.indigo, Colors.purple, Colors.brown, Colors.grey, Colors.black];
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Pick Color'),
      content: Wrap(spacing: 8, runSpacing: 8, children: colors.map((c) => GestureDetector(
        onTap: () {
          setState(() => _color = c);
          Navigator.pop(context);
          if (widget.mqtt.isConnected) {
            widget.mqtt.publish(widget.topic, _colorToHex(c), qos: widget.qos, retain: _retain);
          }
        },
        child: Container(width: 36, height: 36, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _color == c ? Colors.black : Colors.transparent, width: 2))),
      )).toList()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.mqtt.isConnected;
    final hex = _colorToHex(_color);
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
        onTap: ok ? _showPicker : null,
        child: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: _color, shape: BoxShape.circle,
            border: Border.all(color: Colors.black26, width: 2),
            boxShadow: [BoxShadow(color: _color.withValues(alpha: 0.4), blurRadius: 8)],
          ),
          child: ok ? const Icon(Icons.colorize, color: Colors.white, size: 22) : null,
        ),
      ),
      if (!_hideValue) ...[
        const SizedBox(height: 6),
        Text(hex, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.black54)),
      ],
    ]);
  }
}