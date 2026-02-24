import 'package:flutter/material.dart';

// Layout Decorator: purely visual, no MQTT — shows a title/divider
class LiveLayoutDecoratorPanel extends StatelessWidget {
  final Map<String, dynamic> panel;
  const LiveLayoutDecoratorPanel({super.key, required this.panel});

  @override
  Widget build(BuildContext context) {
    final title = panel['panelName'] as String? ?? panel['label'] as String? ?? '';
    final alignment = panel['titleAlignment'] as String? ?? 'Left';
    TextAlign textAlign;
    switch (alignment) {
      case 'Center': textAlign = TextAlign.center; break;
      case 'Right': textAlign = TextAlign.right; break;
      default: textAlign = TextAlign.left;
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
      Text(title, textAlign: textAlign, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 0.5)),
      const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
    ]);
  }
}