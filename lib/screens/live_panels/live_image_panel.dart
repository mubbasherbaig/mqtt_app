import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/mqtt_service.dart';

class LiveImagePanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  const LiveImagePanel({super.key, required this.panel, required this.topic, required this.mqtt});
  @override
  State<LiveImagePanel> createState() => _LiveImagePanelState();
}

class _LiveImagePanelState extends State<LiveImagePanel> {
  String _payload = '';
  VoidCallback? _unsub;

  String get _imageSource => widget.panel['imageSource'] as String? ?? 'URL Payload';

  @override
  void initState() {
    super.initState();
    _unsub = widget.mqtt.subscribe(widget.topic, (p) { if (mounted) setState(() => _payload = p); });
  }

  @override
  void dispose() { _unsub?.call(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_payload.isEmpty) return const Center(child: Icon(Icons.image_outlined, color: Colors.black26, size: 36));
    if (_imageSource == 'URL Payload') {
      return Image.network(_payload, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.black26)),
        loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_imageSource == 'Base64 Payload') {
      try {
        final bytes = base64Decode(_payload.replaceAll(RegExp(r'\s'), ''));
        return Image.memory(bytes, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.black26)));
      } catch (_) {
        return const Center(child: Icon(Icons.broken_image, color: Colors.black26));
      }
    }
    return const Center(child: Text('Unsupported', style: TextStyle(color: Colors.black38, fontSize: 11)));
  }
}