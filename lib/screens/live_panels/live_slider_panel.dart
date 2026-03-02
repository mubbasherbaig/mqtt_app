import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';
import '../../services/notification_service.dart';
import '../../utils/json_utils.dart';

class LiveSliderPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  final int qos;

  const LiveSliderPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
    required this.qos,
  });

  @override
  State<LiveSliderPanel> createState() => _LiveSliderPanelState();
}

class _LiveSliderPanelState extends State<LiveSliderPanel> {
  late double _value;
  VoidCallback? _unsub;
  VoidCallback? _notifUnsub;
  DateTime? _lastReceivedTime;
  DateTime? _lastSentTime;

  double get _min =>
      double.tryParse(widget.panel['payloadMin']?.toString() ?? '0') ?? 0;

  double get _max =>
      double.tryParse(widget.panel['payloadMax']?.toString() ?? '100') ?? 100;

  double get _step =>
      double.tryParse(widget.panel['sliderStep']?.toString() ?? '1') ?? 1;

  bool get _retain => widget.panel['retain'] == true;

  int get _decimals =>
      int.tryParse(widget.panel['decimalPrecision']?.toString() ?? '0') ?? 0;

  bool get _dynamicColor => widget.panel['dynamicColor'] == true;

  bool get _showReceivedTimestamp =>
      widget.panel['showReceivedTimestamp'] == true;

  bool get _showSentTimestamp => widget.panel['showSentTimestamp'] == true;

  bool get _enableNotification => widget.panel['enableNotification'] == true;

  String get _panelName =>
      widget.panel['label'] as String? ??
          widget.panel['panelName'] as String? ??
          'Slider';

  // Separate subscribe topic — used for incoming value display AND notifications
  String get _subTopic {
    final sub = widget.panel['subscribeTopic'] as String? ?? '';
    return sub.trim();
  }

  String get _orientation =>
      widget.panel['orientation'] as String? ??
          widget.panel['sliderOrientation'] as String? ??
          'Horizontal';

  bool get _isVertical => _orientation == 'Vertical';

  Color get _sliderColor {
    if (_dynamicColor) {
      final pct = (_max == _min)
          ? 0.0
          : ((_value - _min) / (_max - _min)).clamp(0.0, 1.0);
      if (pct < 0.5) {
        return Color.lerp(Colors.green, Colors.yellow, pct * 2)!;
      } else {
        return Color.lerp(Colors.yellow, Colors.red, (pct - 0.5) * 2)!;
      }
    }
    final raw = widget.panel['sliderColor'];
    if (raw != null) {
      final parsed = int.tryParse(raw.toString());
      if (parsed != null) return Color(parsed);
    }
    return const Color(0xFF1E88E5);
  }

  String get _displayValue => _decimals > 0
      ? _value.toStringAsFixed(_decimals)
      : _value.toInt().toString();

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _value = _min;
    _subscribe();
  }

  void _subscribe() {
    // Always subscribe to publish topic to sync slider position
    _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
      final jsonPath = widget.panel['jsonPath'] as String? ?? '';
      final extracted = extractJsonValue(payload, jsonPath);
      final v = double.tryParse(extracted);
      if (v != null && mounted) {
        setState(() {
          _value = v.clamp(_min, _max);
          if (_showReceivedTimestamp) _lastReceivedTime = DateTime.now();
        });
      }
    });

    // Only subscribe for notifications on a SEPARATE subscribeTopic
    // This avoids echo notifications when the user moves the slider
    if (_enableNotification && _subTopic.isNotEmpty) {
      _notifUnsub = widget.mqtt.subscribe(_subTopic, (payload) {
        if (!mounted) return;
        final jsonPath = widget.panel['jsonPath'] as String? ?? '';
        final extracted = extractJsonValue(payload, jsonPath);
        final v = double.tryParse(extracted);
        if (v != null) {
          final display = _decimals > 0
              ? v.toStringAsFixed(_decimals)
              : v.toInt().toString();
          NotificationService.show(
            title: _panelName,
            body: '$display received on $_subTopic',
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(LiveSliderPanel old) {
    super.didUpdateWidget(old);
    if (old.topic != widget.topic) {
      _unsub?.call();
      _notifUnsub?.call();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsub?.call();
    _notifUnsub?.call();
    super.dispose();
  }

  void _onChange(double v) {
    final snapped = (_step > 0)
        ? (_min + (((v - _min) / _step).round() * _step)).clamp(_min, _max)
        : v;
    setState(() => _value = snapped);
  }

  void _onChangeEnd(double v) {
    if (!widget.mqtt.isConnected) return;
    final payload = _decimals > 0
        ? _value.toStringAsFixed(_decimals)
        : _value.toInt().toString();
    final jsonPattern = widget.panel['jsonPattern'] as String? ?? '';
    final toSend = buildJsonPayload(payload, jsonPattern);
    widget.mqtt.publish(widget.topic, toSend, qos: widget.qos, retain: _retain);
    if (_showSentTimestamp) setState(() => _lastSentTime = DateTime.now());
  }

  SliderThemeData _sliderTheme(BuildContext context) {
    final color = _sliderColor;
    return SliderTheme.of(context).copyWith(
      activeTrackColor: color,
      thumbColor: color,
      inactiveTrackColor: color.withOpacity(0.2),
    );
  }

  Widget _buildTimestamps() {
    final hasSent = _showSentTimestamp && _lastSentTime != null;
    final hasReceived = _showReceivedTimestamp && _lastReceivedTime != null;
    if (!hasSent && !hasReceived) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasSent)
          Text(
            '↑ ${_formatTime(_lastSentTime!)}',
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
        if (hasSent && hasReceived) const SizedBox(width: 8),
        if (hasReceived)
          Text(
            '↓ ${_formatTime(_lastReceivedTime!)}',
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.mqtt.isConnected;

    if (_isVertical) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _displayValue,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _max.toStringAsFixed(_decimals),
                      style: const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                    Text(
                      _min.toStringAsFixed(_decimals),
                      style: const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                SliderTheme(
                  data: _sliderTheme(context),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: _value.clamp(_min, _max),
                      min: _min,
                      max: _max,
                      onChanged: isConnected ? _onChange : null,
                      onChangeEnd: _onChangeEnd,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTimestamps(),
        ],
      );
    }

    // Horizontal (default)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _displayValue,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: _sliderTheme(context),
          child: Slider(
            value: _value.clamp(_min, _max),
            min: _min,
            max: _max,
            onChanged: isConnected ? _onChange : null,
            onChangeEnd: _onChangeEnd,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _min.toStringAsFixed(_decimals),
              style: const TextStyle(fontSize: 10, color: Colors.black38),
            ),
            Text(
              _max.toStringAsFixed(_decimals),
              style: const TextStyle(fontSize: 10, color: Colors.black38),
            ),
          ],
        ),
        _buildTimestamps(),
      ],
    );
  }
}