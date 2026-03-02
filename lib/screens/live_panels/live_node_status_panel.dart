import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../services/notification_service.dart';
import '../../utils/json_utils.dart';

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
  DateTime? _lastReceivedTime;
  DateTime? _lastSentTime;

  String get _payloadOnline =>
      widget.panel['payloadOnline'] as String? ?? 'online';
  bool get _isOnline => _lastPayload == _payloadOnline;
  bool get _hasReceived => _lastPayload.isNotEmpty;
  bool get _showReceivedTimestamp =>
      widget.panel['showReceivedTimestamp'] == true;
  bool get _showSentTimestamp => widget.panel['showSentTimestamp'] == true;

  bool get _enableNotification => widget.panel['enableNotification'] == true;

  String get _panelName =>
      widget.panel['label'] as String? ??
          widget.panel['panelName'] as String? ??
          'Node Status';

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _subscribe();
    if (widget.panel['autoSyncOnLoad'] == true) {
      final syncPayload = widget.panel['payloadSyncRequest'] as String? ?? '';
      if (syncPayload.isNotEmpty && widget.mqtt.isConnected) {
        widget.mqtt.publish(widget.topic, syncPayload);
        if (_showSentTimestamp) {
          setState(() => _lastSentTime = DateTime.now());
        }
      }
    }
  }

  void _subscribe() {
    _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
      if (!mounted) return;
      final jsonPath = widget.panel['jsonPath'] as String? ?? '';
      final extracted = extractJsonValue(payload, jsonPath);
      final wasOnline = _isOnline;
      setState(() {
        _lastPayload = extracted;
        if (_showReceivedTimestamp) _lastReceivedTime = DateTime.now();
      });
      // Notify only on Online → Offline transition
      if (_enableNotification && wasOnline && extracted != _payloadOnline) {
        NotificationService.show(
          title: _panelName,
          body: 'Device went OFFLINE on ${widget.topic}',
        );
      }
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
            color: dotColor,
          ),
        ),
        if (_hasReceived && _lastPayload.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            _lastPayload,
            style: const TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
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