import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveBarcodeScannerPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;
  const LiveBarcodeScannerPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
    required this.qos,
  });
  @override
  State<LiveBarcodeScannerPanel> createState() => _LiveBarcodeScannerPanelState();
}

class _LiveBarcodeScannerPanelState extends State<LiveBarcodeScannerPanel> {
  String _lastScanned = '';
  bool _sent = false;
  DateTime? _lastSentTime;

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

  bool get _retain => widget.panel['retain'] == true;
  bool get _confirmBeforePublish => widget.panel['confirmBeforePublish'] == true;
  bool get _showSentTimestamp => widget.panel['showSentTimestamp'] == true;

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  Future<void> _simulateScan() async {
    final ctrl = TextEditingController();
    final val = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Scan / Enter Barcode'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Enter barcode value'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (val == null || val.isEmpty) return;
    if (!widget.mqtt.isConnected) return;

    // confirmBeforePublish dialog
    if (_confirmBeforePublish) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm'),
          content: Text('Publish "$val" to ${widget.topic}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Send'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
    final toSend = buildJsonPayload(val, jsonPattern);
    widget.mqtt.publish(widget.topic, toSend, qos: widget.qos, retain: _retain);

    if (mounted) {
      setState(() {
        _lastScanned = val;
        _sent = true;
        if (_showSentTimestamp) _lastSentTime = DateTime.now();
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _sent = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.mqtt.isConnected;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (_lastScanned.isNotEmpty) ...[
        Text(
          _lastScanned,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
      ],
      SizedBox(
        height: _btnHeight,
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: ok ? (_sent ? Colors.green : _color) : Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: ok ? _simulateScan : null,
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
          label: Text(
            _sent ? '✓ Sent' : 'SCAN',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      if (_showSentTimestamp && _lastSentTime != null) ...[
        const SizedBox(height: 4),
        Text(
          '↑ ${_formatTime(_lastSentTime!)}',
          style: const TextStyle(fontSize: 10, color: Colors.black45),
        ),
      ],
    ]);
  }
}