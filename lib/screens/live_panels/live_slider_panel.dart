
import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';

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

  double get _min =>
      double.tryParse(widget.panel['payloadMin']?.toString() ?? '0') ?? 0;
  double get _max =>
      double.tryParse(widget.panel['payloadMax']?.toString() ?? '100') ?? 100;
  double get _step =>
      double.tryParse(widget.panel['sliderStep']?.toString() ?? '1') ?? 1;
  bool get _retain => widget.panel['retain'] == true;
  int get _decimals =>
      int.tryParse(widget.panel['decimalPrecision']?.toString() ?? '0') ?? 0;

  Color get _sliderColor {
    final raw = widget.panel['sliderColor'];
    if (raw != null) {
      final parsed = int.tryParse(raw.toString());
      if (parsed != null) return Color(parsed);
    }
    return const Color(0xFF1E88E5);
  }

  @override
  void initState() {
    super.initState();
    _value = _min;
    _subscribe();
  }

  void _subscribe() {
    _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
      final v = double.tryParse(payload);
      if (v != null && mounted) {
        setState(() => _value = v.clamp(_min, _max));
      }
    });
  }

  @override
  void didUpdateWidget(LiveSliderPanel old) {
    super.didUpdateWidget(old);
    if (old.topic != widget.topic) {
      _unsub?.call();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsub?.call();
    super.dispose();
  }

  void _onChange(double v) {
    // Snap to step
    final snapped = (_step > 0)
        ? (_min + (((v - _min) / _step).round() * _step))
        .clamp(_min, _max)
        : v;
    setState(() => _value = snapped);
  }

  void _onChangeEnd(double v) {
    if (!widget.mqtt.isConnected) return;
    final payload = _decimals > 0
        ? _value.toStringAsFixed(_decimals)
        : _value.toInt().toString();
    widget.mqtt.publish(widget.topic, payload,
        qos: widget.qos, retain: _retain);
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.mqtt.isConnected;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _decimals > 0
              ? _value.toStringAsFixed(_decimals)
              : _value.toInt().toString(),
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _sliderColor,
            thumbColor: _sliderColor,
            inactiveTrackColor: _sliderColor.withOpacity(0.2),
          ),
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
            Text(_min.toInt().toString(),
                style:
                const TextStyle(fontSize: 10, color: Colors.black38)),
            Text(_max.toInt().toString(),
                style:
                const TextStyle(fontSize: 10, color: Colors.black38)),
          ],
        ),
      ],
    );
  }
}