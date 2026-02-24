import 'package:flutter/material.dart';
import '../../services/mqtt_service.dart';

class LiveTextOutputPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;

  const LiveTextOutputPanel({
    super.key,
    required this.panel,
    required this.topic,
    required this.mqtt,
  });

  @override
  State<LiveTextOutputPanel> createState() => _LiveTextOutputPanelState();
}

class _LiveTextOutputPanelState extends State<LiveTextOutputPanel> {
  String _value = '—';
  final List<String> _history = [];
  VoidCallback? _unsub;
  DateTime? _lastReceived;

  bool get _showHistory => widget.panel['showHistory'] == true;
  bool get _showTimestamp => widget.panel['showReceivedTimestamp'] == true;
  double get _textSize {
    final s = widget.panel['textSize'] as String? ?? 'Medium';
    switch (s) {
      case 'Small':  return 12;
      case 'Large':  return 20;
      default:       return 15;
    }
  }

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
      if (!mounted) return;
      setState(() {
        _value = payload;
        _lastReceived = DateTime.now();
        if (_showHistory) {
          _history.insert(0, payload);
          if (_history.length > 50) _history.removeLast();
        }
      });
    });
  }

  @override
  void didUpdateWidget(LiveTextOutputPanel old) {
    super.didUpdateWidget(old);
    if (old.topic != widget.topic) {
      _unsub?.call();
      _history.clear();
      _value = '—';
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
    if (_showHistory && _history.isNotEmpty) {
      return ListView.builder(
        reverse: false,
        itemCount: _history.length,
        itemBuilder: (_, i) => Text(
          _history[i],
          style: TextStyle(fontSize: _textSize - 2, color: Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _value,
          style: TextStyle(
              fontSize: _textSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (_showTimestamp && _lastReceived != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatTime(_lastReceived!),
            style: const TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}