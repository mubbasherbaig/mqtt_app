import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';

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

  Color get _buttonColor {
    final raw = widget.panel['buttonColor'];
    if (raw != null) {
      final parsed = int.tryParse(raw.toString());
      if (parsed != null) return Color(parsed);
    }
    return const Color(0xFF1E88E5);
  }

  String get _payload => widget.panel['payload'] as String? ?? '';
  String get _releasePayload =>
      widget.panel['separatePayload'] as String? ?? '';
  bool get _noPayload => widget.panel['noPayload'] == true;
  int get _qos =>
      int.tryParse(widget.panel['qos']?.toString() ?? '0') ?? 0;
  bool get _retain => widget.panel['retain'] == true;

  void _publish() {
    if (_noPayload) return;
    widget.mqtt.publish(widget.topic, _payload,
        qos: _qos, retain: _retain);
  }

  void _publishRelease() {
    if (_releasePayload.isNotEmpty) {
      widget.mqtt.publish(widget.topic, _releasePayload,
          qos: _qos, retain: _retain);
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