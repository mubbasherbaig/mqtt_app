import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/mqtt_service.dart';

class LiveUriLauncherPanel extends StatefulWidget {
  final Map<String, dynamic> panel;
  final String topic;
  final MqttService mqtt;
  const LiveUriLauncherPanel({super.key, required this.panel, required this.topic, required this.mqtt});
  @override
  State<LiveUriLauncherPanel> createState() => _LiveUriLauncherPanelState();
}

class _LiveUriLauncherPanelState extends State<LiveUriLauncherPanel> {
  String _dynamicUrl = '';
  VoidCallback? _unsub;

  String get _staticUrl => widget.panel['staticUrl'] as String? ?? '';
  String get _effectiveUrl => _dynamicUrl.isNotEmpty ? _dynamicUrl : _staticUrl;

  @override
  void initState() {
    super.initState();
    if (widget.topic.isNotEmpty) {
      _unsub = widget.mqtt.subscribe(widget.topic, (payload) {
        if (mounted) setState(() => _dynamicUrl = payload);
      });
    }
  }

  @override
  void dispose() { _unsub?.call(); super.dispose(); }

  void _launch() async {
    final url = _effectiveUrl;
    if (url.isEmpty) return;
    // Try platform channel to open URL; works on Android/iOS
    const channel = MethodChannel('flutter/platform');
    try {
      await channel.invokeMethod('openUri', {'uri': url});
    } catch (_) {
      // Copy URL to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL copied: $url'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = _effectiveUrl.isNotEmpty;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (hasUrl) ...[
        Text(_effectiveUrl, style: const TextStyle(fontSize: 10, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
      ],
      SizedBox(
        height: 36, width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: hasUrl ? const Color(0xFF1E88E5) : Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: hasUrl ? _launch : null,
          icon: const Icon(Icons.open_in_new, color: Colors.white, size: 16),
          label: const Text('OPEN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }
}