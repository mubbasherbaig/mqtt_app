import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../services/notification_service.dart';

class LiveImagePanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  const LiveImagePanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
  });
  @override
  State<LiveImagePanel> createState() => _LiveImagePanelState();
}

class _LiveImagePanelState extends State<LiveImagePanel> {
  String _payload = '';
  VoidCallback? _unsub;
  Timer? _refreshTimer;
  DateTime? _lastReceivedTime;
  // Incrementing key forces Image.network to reload on autoRefresh
  int _imageKey = 0;

  String get _imageSource => widget.panel['imageSource'] as String? ?? 'URL Payload';
  bool get _autoRefresh => widget.panel['autoRefresh'] == true;
  bool get _fitToPanelWidth => widget.panel['fitToPanelWidth'] == true;
  bool get _showReceivedTimestamp => widget.panel['showReceivedTimestamp'] == true;

  bool get _enableNotification => widget.panel['enableNotification'] == true;

  String get _panelName =>
      widget.panel['label'] as String? ??
          widget.panel['panelName'] as String? ??
          'Image';

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _unsub = widget.mqtt.subscribe(widget.topic, (p) {
      if (!mounted) return;
      setState(() {
        _payload = p;
        if (_showReceivedTimestamp) _lastReceivedTime = DateTime.now();
      });
      if (_enableNotification) {
        NotificationService.show(
          title: _panelName,
          body: 'New image received on ${widget.topic}',
        );
      }
    });

    // autoRefresh: bump the image key every 5 seconds to force re-fetch of URL images
    if (_autoRefresh && _imageSource == 'URL Payload') {
      _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted && _payload.isNotEmpty) {
          setState(() => _imageKey++);
        }
      });
    }
  }

  @override
  void dispose() {
    _unsub?.call();
    _refreshTimer?.cancel();
    super.dispose();
  }

  BoxFit get _fit => _fitToPanelWidth ? BoxFit.fitWidth : BoxFit.contain;

  Widget _buildImage() {
    if (_payload.isEmpty) {
      return const Center(
        child: Icon(Icons.image_outlined, color: Colors.black26, size: 36),
      );
    }

    if (_imageSource == 'URL Payload') {
      return Image.network(
        _payload,
        key: ValueKey('img_$_imageKey'),
        fit: _fit,
        width: _fitToPanelWidth ? double.infinity : null,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.black26),
        ),
        loadingBuilder: (_, child, progress) =>
        progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_imageSource == 'Base64 Payload') {
      try {
        final bytes = base64Decode(_payload.replaceAll(RegExp(r'\s'), ''));
        return Image.memory(
          bytes,
          fit: _fit,
          width: _fitToPanelWidth ? double.infinity : null,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.black26),
          ),
        );
      } catch (_) {
        return const Center(child: Icon(Icons.broken_image, color: Colors.black26));
      }
    }

    return const Center(
      child: Text('Unsupported', style: TextStyle(color: Colors.black38, fontSize: 11)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: _buildImage()),
        if (_showReceivedTimestamp && _lastReceivedTime != null) ...[
          const SizedBox(height: 2),
          Text(
            '↓ ${_formatTime(_lastReceivedTime!)}',
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
          const SizedBox(height: 2),
        ],
      ],
    );
  }
}