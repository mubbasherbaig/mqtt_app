import 'package:flutter/material.dart';

class AddLayoutDecoratorPanelScreen extends StatefulWidget {
  const AddLayoutDecoratorPanelScreen({super.key});
  @override
  State<AddLayoutDecoratorPanelScreen> createState() => _AddLayoutDecoratorPanelScreenState();
}

class _AddLayoutDecoratorPanelScreenState extends State<AddLayoutDecoratorPanelScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();

  String _titleAlignment = 'Center';
  String _textSize       = '20px';

  final List<String> _alignments = ['Left', 'Center', 'Right'];
  final List<String> _textSizes  = ['12px', '14px', '16px', '18px', '20px', '24px', '28px', '32px'];

  @override
  void dispose() { _panelNameCtrl.dispose(); super.dispose(); }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Layout Decorator', 'label': _panelNameCtrl.text.trim(),
        'titleAlignment': _titleAlignment, 'textSize': _textSize,
      });
    }
  }

  Widget _d() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: const Text('Add a Layout Decorator panel', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade300, height: 1))),
      body: Form(key: _formKey, child: ListView(children: [
        // Info description
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Text(
            'This panel neither subscribe nor publishes any data. This panel is for decoration purpose only. It is useful to create header label for combo panels.',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ),
        // Panel name
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(text: const TextSpan(text: 'Panel name', style: TextStyle(fontSize: 15, color: Colors.black87),
                children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
            TextFormField(controller: _panelNameCtrl,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))),
                    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                    focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)))),
          ])),
          _d(),
        ]),
        // Title alignment + Text size on same row
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Title alignment', style: TextStyle(fontSize: 13, color: Colors.black54)),
              DropdownButtonFormField<String>(value: _titleAlignment, style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26))),
                  items: _alignments.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                  onChanged: (v) => setState(() => _titleAlignment = v!)),
            ])),
            const SizedBox(width: 24),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Text size', style: TextStyle(fontSize: 13, color: Colors.black54)),
              DropdownButtonFormField<String>(value: _textSize, style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26))),
                  items: _textSizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _textSize = v!)),
            ])),
          ])),
          _d(),
        ]),
        Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 36), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: 130, height: 44, child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.8)))),
          const SizedBox(width: 16),
          SizedBox(width: 130, height: 44, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), elevation: 2),
              onPressed: _create,
              child: const Text('CREATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.8)))),
        ])),
      ])),
    );
  }
}