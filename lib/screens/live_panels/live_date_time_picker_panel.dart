import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveDateTimePickerPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;
  const LiveDateTimePickerPanel({super.key, required this.panel, required this.topic, required this.mqtt, required this.qos});
  @override
  State<LiveDateTimePickerPanel> createState() => _LiveDateTimePickerPanelState();
}

class _LiveDateTimePickerPanelState extends State<LiveDateTimePickerPanel> {
  String _lastSent = '';
  bool _sent = false;

  String get _pickerType => widget.panel['pickerType'] as String? ?? 'Date Time';
  bool get _retain => widget.panel['retain'] == true;

  Color get _color {
    final v = int.tryParse(widget.panel['buttonColor']?.toString() ?? '');
    return v != null ? Color(v) : const Color(0xFF1E88E5);
  }

  double get _btnHeight {
    switch (widget.panel['buttonSize'] as String? ?? 'Medium') {
      case 'Small': return 28;
      case 'Large': return 44;
      default: return 36;
    }
  }

  Future<void> _pick() async {
    if (!widget.mqtt.isConnected) return;
    String? result;
    final now = DateTime.now();

    if (_pickerType == 'Date' || _pickerType == 'Date Time') {
      final date = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: DateTime(2100));
      if (date == null) return;
      if (_pickerType == 'Date') {
        result = '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
      } else {
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (time == null) return;
        result = '${date.year}-${_pad(date.month)}-${_pad(date.day)} ${_pad(time.hour)}:${_pad(time.minute)}';
      }
    } else {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time == null) return;
      result = '${_pad(time.hour)}:${_pad(time.minute)}';
    }

    if (result != null) {
      final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
      final toSend = buildJsonPayload(result!, jsonPattern);
      widget.mqtt.publish(widget.topic, toSend, qos: widget.qos, retain: _retain);
      setState(() { _lastSent = result!; _sent = true; });
      Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _sent = false); });
    }
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final ok = widget.mqtt.isConnected;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (_lastSent.isNotEmpty) Text(_lastSent, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
      if (_lastSent.isNotEmpty) const SizedBox(height: 6),
      SizedBox(
        height: _btnHeight, width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: ok ? (_sent ? Colors.green : _color) : Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
          onPressed: ok ? _pick : null,
          icon: Icon(_pickerType == 'Time' ? Icons.access_time : Icons.calendar_today, color: Colors.white, size: 16),
          label: Text(_sent ? '✓ Sent' : _pickerType, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }
}