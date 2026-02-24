import 'package:flutter/material.dart';

class AddUriLauncherPanelScreen extends StatefulWidget {
  const AddUriLauncherPanelScreen({super.key});
  @override
  State<AddUriLauncherPanelScreen> createState() => _AddUriLauncherPanelScreenState();
}

class _AddUriLauncherPanelScreenState extends State<AddUriLauncherPanelScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _topicCtrl     = TextEditingController();

  bool _disableDashboardPrefix = false;
  bool _staticUrl              = false;
  bool _enableNotification     = false;
  bool _payloadIsJson          = false;
  bool _showReceivedTimestamp  = false;
  int  _qos                    = 0;

  final List<int> _qosOptions = [0, 1, 2];

  @override
  void dispose() { _panelNameCtrl.dispose(); _topicCtrl.dispose(); super.dispose(); }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'URI Launcher', 'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(), 'staticUrl': _staticUrl, 'qos': _qos,
      });
    }
  }

  Widget _d() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));
  Widget _help() => Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle), child: const Icon(Icons.question_mark, color: Colors.white, size: 15));

  Widget _field(String label, TextEditingController ctrl, {bool req = false, bool showHelp = false, String? Function(String?)? val}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(text: TextSpan(text: label, style: const TextStyle(fontSize: 15, color: Colors.black87),
              children: req ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [])),
          TextFormField(controller: ctrl, validator: val, style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)))),
        ])),
        if (showHelp) Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: _help()),
      ])),
      _d(),
    ]);
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged, {bool help = false, bool enabled = true}) {
    return Column(children: [
      InkWell(onTap: enabled ? () => onChanged(!value) : null,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(children: [
            SizedBox(width: 28, height: 28, child: Checkbox(value: value, onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: enabled ? Colors.black54 : Colors.black26, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: enabled ? Colors.black87 : Colors.black38))),
            if (help) _help(),
          ]))),
      _d(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: const Text('Add an URI Launcher panel', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade300, height: 1))),
      body: Form(key: _formKey, child: ListView(children: [
        _field('Panel name', _panelNameCtrl, req: true, val: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _check('Disable dashboard prefix topic', _disableDashboardPrefix, (v) => setState(() => _disableDashboardPrefix = v), help: true),
        _field('Topic', _topicCtrl, req: true, val: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _check('Static URL', _staticUrl, (v) => setState(() => _staticUrl = v)),
        _check('Enable notification or alarm', _enableNotification, (v) => setState(() => _enableNotification = v), help: true, enabled: false),
        _check('Payload is JSON Data', _payloadIsJson, (v) => setState(() => _payloadIsJson = v)),
        _check('Show received timestamp', _showReceivedTimestamp, (v) => setState(() => _showReceivedTimestamp = v)),
        Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Row(children: [
            const Spacer(),
            const Text('QoS', style: TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(width: 8),
            DropdownButton<int>(value: _qos, underline: Container(height: 1, color: Colors.black26),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                items: _qosOptions.map((q) => DropdownMenuItem(value: q, child: Text('$q'))).toList(),
                onChanged: (v) => setState(() => _qos = v!)),
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