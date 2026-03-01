import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveTextInputPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;

  const LiveTextInputPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
    required this.qos,
  });

  @override
  State<LiveTextInputPanel> createState() => _LiveTextInputPanelState();
}

class _LiveTextInputPanelState extends State<LiveTextInputPanel> {
  final _ctrl = TextEditingController();
  bool _sent = false;

  VoidCallback? _unsub;

  bool get _clearOnPublish => widget.panel['clearTextOnPublish'] == true;
  bool get _retain => widget.panel['retain'] == true;
  String get _subTopic {
    final sub = widget.panel['subscribeTopic'] as String? ?? '';
    return sub.isNotEmpty ? sub : '';
  }

  bool get _confirmBeforePublish =>
      widget.panel['confirmBeforePublish'] == true;

  @override
  void initState() {
    super.initState();
    if (_subTopic.isNotEmpty) {
      _unsub = widget.mqtt.subscribe(_subTopic, (payload) {
        if (!mounted) return;
        final jsonPath = widget.panel['jsonPath'] as String? ?? '';
        final extracted = extractJsonValue(payload, jsonPath);
        _ctrl.text = extracted;
      });
    }
  }

  @override
  void dispose() {
    _unsub?.call();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || !widget.mqtt.isConnected) return;

    if (_confirmBeforePublish) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm publish'),
          content: Text('Publish "$text" to ${widget.topic}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Publish')),
          ],
        ),
      );
      if (ok != true) return;
    }

    final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
    final toSend = buildJsonPayload(text, jsonPattern);
    widget.mqtt.publish(widget.topic, toSend, qos: widget.qos, retain: _retain);

    setState(() => _sent = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _sent = false);
    });

    if (_clearOnPublish) _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.mqtt.isConnected;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _ctrl,
          enabled: isConnected,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6)),
            hintText: isConnected ? 'Type message…' : 'Offline',
            hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
          ),
          onSubmitted: (_) => _send(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 32,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _sent
                  ? Colors.green
                  : (isConnected
                  ? const Color(0xFF1E88E5)
                  : Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: isConnected ? _send : null,
            child: Text(
              _sent ? '✓ Sent' : 'SEND',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}