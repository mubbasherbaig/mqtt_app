import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveBarcodeScannerPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;
  const LiveBarcodeScannerPanel({super.key, required this.panel, required this.topic, required this.mqtt, required this.qos});
  @override
  State<LiveBarcodeScannerPanel> createState() => _LiveBarcodeScannerPanelState();
}

class _LiveBarcodeScannerPanelState extends State<LiveBarcodeScannerPanel> {
  String _lastScanned = '';
  bool _sent = false;

  Color get _color {
    final v = int.tryParse(widget.panel['buttonColor']?.toString() ?? '');
    return v != null ? Color(v) : const Color(0xFF1E88E5);
  }

  double get _btnHeight {
    switch (widget.panel['buttonSize'] as String? ?? 'Medium') {
      case 'Small': return 28; case 'Large': return 44; default: return 36;
    }
  }

  bool get _retain => widget.panel['retain'] == true;

  void _simulateScan() {
    showDialog(context: context, builder: (_) {
      final ctrl = TextEditingController();
      return AlertDialog(
        title: const Text('Scan / Enter Barcode'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Enter barcode value'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            final val = ctrl.text.trim();
            Navigator.pop(context);
            if (val.isNotEmpty && widget.mqtt.isConnected) {
              final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
              final toSend = buildJsonPayload(val, jsonPattern);
              widget.mqtt.publish(widget.topic, toSend, qos: widget.qos, retain: _retain);
              setState(() { _lastScanned = val; _sent = true; });
              Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _sent = false); });
            }
          }, child: const Text('Send')),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.mqtt.isConnected;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (_lastScanned.isNotEmpty) ...[
        Text(_lastScanned, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
        const SizedBox(height: 6),
      ],
      SizedBox(
        height: _btnHeight, width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: ok ? (_sent ? Colors.green : _color) : Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
          onPressed: ok ? _simulateScan : null,
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
          label: Text(_sent ? '✓ Sent' : 'SCAN', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }
}