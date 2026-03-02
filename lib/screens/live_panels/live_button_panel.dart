import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../utils/json_utils.dart';
import '../widgets/icon_picker_sheet.dart';

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
  Timer? _repeatTimer;
  DateTime? _lastSentTime;

  // ── Getters ───────────────────────────────────────────────

  String get _payload => widget.panel['payload'] as String? ?? '';
  String get _releasePayload => widget.panel['separatePayload'] as String? ?? '';
  bool get _noPayload => widget.panel['noPayload'] == true;
  int get _qos => int.tryParse(widget.panel['qos']?.toString() ?? '0') ?? 0;
  bool get _retain => widget.panel['retain'] == true;
  bool get _repeatPublish => widget.panel['repeatPublish'] == true;
  bool get _fitToPanelWidth => widget.panel['fitToPanelWidth'] == true;
  bool get _useIconsForButton => widget.panel['useIconsForButton'] == true;
  bool get _showSentTimestamp => widget.panel['showSentTimestamp'] == true;
  bool get _confirmBeforePublish => widget.panel['confirmBeforePublish'] == true;

  double get _buttonHeight {
    switch (widget.panel['buttonSize'] as String? ?? 'Medium') {
      case 'Small': return 36;
      case 'Large': return 64;
      default: return 52; // Medium
    }
  }

  IconData get _panelIcon {
    final iconStr = widget.panel['icon'] as String?;
    if (iconStr != null) return iconFromString(iconStr) ?? Icons.touch_app;
    return Icons.touch_app;
  }

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

  Color get _buttonColor {
    if (_subTopic.isNotEmpty && _receivedPayload.isNotEmpty) {
      final configPayload = widget.panel['payload'] as String? ?? '';
      if (_receivedPayload == configPayload) return _activeButtonColor;
      return _activeButtonColor.withOpacity(0.35);
    }
    return _activeButtonColor;
  }

  // ── Lifecycle ─────────────────────────────────────────────

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
    _repeatTimer?.cancel();
    super.dispose();
  }

  // ── Publish logic ─────────────────────────────────────────

  void _publish() {
    if (_noPayload) return;
    if (!widget.mqtt.isConnected) return;
    final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
    final toSend = buildJsonPayload(_payload, jsonPattern);
    widget.mqtt.publish(widget.topic, toSend, qos: _qos, retain: _retain);
    if (_showSentTimestamp) {
      setState(() => _lastSentTime = DateTime.now());
    }
  }

  void _publishRelease() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    if (_releasePayload.isNotEmpty && widget.mqtt.isConnected) {
      final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
      final toSend = buildJsonPayload(_releasePayload, jsonPattern);
      widget.mqtt.publish(widget.topic, toSend, qos: _qos, retain: _retain);
    }
  }

  Future<void> _onTapDown() async {
    if (!widget.mqtt.isConnected) return;

    if (_confirmBeforePublish) {
      final label = widget.panel['panelName'] as String? ?? widget.panel['label'] as String? ?? 'Button';
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm'),
          content: Text('Publish to ${widget.topic}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Publish')),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => _pressed = true);
    _publish();

    if (_repeatPublish) {
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted || !widget.mqtt.isConnected) {
          _repeatTimer?.cancel();
          return;
        }
        _publish();
      });
    }
  }

  void _onTapUp() {
    setState(() => _pressed = false);
    _publishRelease();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  // ── Build ─────────────────────────────────────────────────

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.mqtt.isConnected;
    final color = isConnected ? (_pressed ? _buttonColor.withOpacity(0.7) : _buttonColor) : Colors.grey.shade300;

    // Button width: fitToPanelWidth = true → full width (double.infinity already),
    // false → wrap to content with min width
    final buttonWidth = _fitToPanelWidth ? double.infinity : null;

    Widget buttonChild;
    if (_useIconsForButton) {
      buttonChild = Icon(_panelIcon, color: Colors.white, size: _buttonHeight * 0.45);
    } else {
      final label = widget.panel['panelName'] as String? ?? widget.panel['label'] as String? ?? 'PRESS';
      buttonChild = Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.8,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: GestureDetector(
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            onTapCancel: _onTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: buttonWidth ?? null,
              constraints: buttonWidth == null
                  ? const BoxConstraints(minWidth: 80)
                  : null,
              height: _buttonHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: _pressed
                    ? []
                    : [
                  BoxShadow(
                    color: _buttonColor.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: buttonChild,
            ),
          ),
        ),
        if (_showSentTimestamp && _lastSentTime != null) ...[
          const SizedBox(height: 4),
          Text(
            '✓ ${_formatTime(_lastSentTime!)}',
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
        ],
      ],
    );
  }
}