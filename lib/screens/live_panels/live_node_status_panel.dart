import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';

class LiveNodeStatusPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;

  const LiveNodeStatusPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
  });

  @override
  State<LiveNodeStatusPanel> createState() => _LiveNodeStatusPanelState();
}

class _LiveNodeStatusPanelState extends State<LiveNodeStatusPanel> {
  String _lastPayload = '';
  VoidCallback? _unsub;

  String get _payloadOnline =>
      widget.panel['payloadOnline'] as String? ?? 'online';

  bool get _isOnline => _lastPayload == _payloadOnline;
  bool get _hasReceived => _lastPayload.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _subscribe();

    // Auto-sync on load: publish sync request if configured
    if (widget.panel['autoSyncOnLoad'] == true) {
      final syncPayload = widget.panel['payloadSyncRequest'] as String? ?? '';
      if (syncPayload.isNotEmpty && widget.mqtt.isConnected) {
        widget.mqtt.publish(widget.topic, syncPayload);
      }
    }
  }

  void _subscribe() {
    _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
      if (!mounted) return;
      setState(() => _lastPayload = payload);
    });
  }

  @override
  void didUpdateWidget(LiveNodeStatusPanel old) {
    super.didUpdateWidget(old);
    if (old.topic != widget.topic) {
      _unsub?.call();
      _lastPayload = '';
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsub?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String statusText;
    IconData icon;

    if (!_hasReceived) {
      dotColor = Colors.grey;
      statusText = 'Waiting…';
      icon = Icons.wifi_find;
    } else if (_isOnline) {
      dotColor = Colors.green;
      statusText = 'Online';
      icon = Icons.wifi;
    } else {
      dotColor = Colors.red;
      statusText = 'Offline';
      icon = Icons.wifi_off;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: dotColor.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 2),
          ),
          child: Icon(icon, color: dotColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          statusText,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dotColor),
        ),
        if (_hasReceived && _lastPayload.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            _lastPayload,
            style: const TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ],
    );
  }
}