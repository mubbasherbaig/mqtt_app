import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';

class LiveButtonPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;

  const LiveButtonPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
  });

  @override
  State<LiveButtonPanel> createState() => _LiveButtonPanelState();
}

class _LiveButtonPanelState extends State<LiveButtonPanel> {
  bool _pressed = false;

  String _receivedPayload = '';
  VoidCallback? _unsub;

  Color get _buttonColor {
    // If we have a received payload matching configured payload, use active color
    // Otherwise dim it to show the OFF state
    if (_subTopic.isNotEmpty && _receivedPayload.isNotEmpty) {
      final configPayload = widget.panel['payload'] as String? ?? '';
      if (_receivedPayload == configPayload) return _activeButtonColor;
      return _activeButtonColor.withOpacity(0.35);
    }
    return _activeButtonColor;
  }

  String get _payload => widget.panel['payload'] as String? ?? '';
  String get _releasePayload =>
      widget.panel['separatePayload'] as String? ?? '';
  bool get _noPayload => widget.panel['noPayload'] == true;
  int get _qos =>
      int.tryParse(widget.panel['qos']?.toString() ?? '0') ?? 0;
  bool get _retain => widget.panel['retain'] == true;

  String get _subTopic {
    final sub = widget.panel['subscribeTopic'] as String? ?? '';
    return sub.isNotEmpty ? sub : '';
  }

  Color get _activeButtonColor {
    final raw = widget.panel['buttonColor'];
    if (raw != null) {
      final parsed = int.tryParse(raw.toString());
      if (parsed != null) return Color(parsed);
    }
    return const Color(0xFF1E88E5);
  }

  @override
  void initState() {
    super.initState();
    if (_subTopic.isNotEmpty) {
      _unsub = widget.mqtt.subscribe(_subTopic, (payload) {
        if (!mounted) return;
        final jsonPath = widget.panel['jsonPath'] as String? ?? '';
        final extracted = extractJsonValue(payload, jsonPath);
        setState(() => _receivedPayload = extracted);
      });
    }
  }

  @override
  void dispose() {
    _unsub?.call();
    super.dispose();
  }

  void _publish() {
    if (_noPayload) return;
    final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
    final toSend = buildJsonPayload(_payload, jsonPattern);
    widget.mqtt.publish(widget.topic, toSend, qos: _qos, retain: _retain);
  }

  void _publishRelease() {
    if (_releasePayload.isNotEmpty) {
      final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
      final toSend = buildJsonPayload(_releasePayload, jsonPattern);
      widget.mqtt.publish(widget.topic, toSend, qos: _qos, retain: _retain);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.mqtt.isConnected;

    return Center(
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
          _publish();
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          _publishRelease();
        },
        onTapCancel: () {
          setState(() => _pressed = false);
          _publishRelease();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: isConnected
                ? (_pressed
                ? _buttonColor.withOpacity(0.7)
                : _buttonColor)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _pressed
                ? []
                : [
              BoxShadow(
                  color: _buttonColor.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 3))
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.panel['panelName'] as String? ?? widget.panel['label'] as String? ?? 'PRESS',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.8),
          ),
        ),
      ),
    );
  }
}