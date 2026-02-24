import 'package:flutter/material.dart';

class AddTextOutputPanelScreen extends StatefulWidget {
  const AddTextOutputPanelScreen({super.key});
  @override
  State<AddTextOutputPanelScreen> createState() => _AddTextOutputPanelScreenState();
}

class _AddTextOutputPanelScreenState extends State<AddTextOutputPanelScreen> {
  final _formKey               = GlobalKey<FormState>();
  final _panelNameCtrl         = TextEditingController();
  final _topicCtrl             = TextEditingController();
  final _factorCtrl            = TextEditingController(text: '1');
  final _decimalPrecisionCtrl  = TextEditingController();
  final _unitCtrl              = TextEditingController();

  bool   _disableDashboardPrefix  = false;
  bool   _showHistory             = false;
  bool   _digitalFont             = false;
  bool   _hideTopic               = false;
  bool   _enableNotification      = false;
  bool   _payloadIsJson           = false;
  bool   _showReceivedTimestamp   = false;

  String _textSize  = '20px';
  int    _qos       = 0;

  final List<String> _textSizes  = ['12px', '14px', '16px', '18px', '20px', '24px', '28px', '32px'];
  final List<int>    _qosOptions = [0, 1, 2];

  @override
  void dispose() { _panelNameCtrl.dispose(); _topicCtrl.dispose(); _factorCtrl.dispose(); _decimalPrecisionCtrl.dispose(); _unitCtrl.dispose(); super.dispose(); }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Text Output', 'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(), 'factor': _factorCtrl.text.trim(),
        'decimalPrecision': _decimalPrecisionCtrl.text.trim(), 'unit': _unitCtrl.text.trim(),
        'textSize': _textSize, 'qos': _qos,
      });
    }
  }

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));
  Widget _helpIcon() => Container(width: 28, height: 28,
      decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
      child: const Icon(Icons.question_mark, color: Colors.white, size: 15));

  Widget _fieldRow(String label, TextEditingController ctrl, {bool required = false, bool showHelp = false, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          RichText(text: TextSpan(text: label, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
              children: required ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [])),
          TextFormField(controller: ctrl, validator: validator,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)))),
        ])),
        if (showHelp) Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: _helpIcon()),
      ])),
      _divider(),
    ]);
  }

  Widget _doubleRow(String label1, TextEditingController ctrl1, String label2, Widget right) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label1, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          TextFormField(controller: ctrl1, keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
        ])),
        const SizedBox(width: 24),
        Expanded(child: right),
      ])),
      _divider(),
    ]);
  }

  Widget _checkRow(String label, bool value, ValueChanged<bool> onChanged, {bool showHelp = false, bool enabled = true}) {
    return Column(children: [
      InkWell(onTap: enabled ? () => onChanged(!value) : null,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(children: [
            SizedBox(width: 28, height: 28, child: Checkbox(value: value,
                onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: enabled ? Colors.black54 : Colors.black26, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: enabled ? Colors.black87 : Colors.black38))),
            if (showHelp) _helpIcon(),
          ]))),
      _divider(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: const Text('Add a Text Output panel', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade300, height: 1))),
      body: Form(key: _formKey, child: ListView(children: [
        _fieldRow('Panel name', _panelNameCtrl, required: true, validator: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _checkRow('Disable dashboard prefix topic', _disableDashboardPrefix, (v) => setState(() => _disableDashboardPrefix = v), showHelp: true),
        _fieldRow('Topic', _topicCtrl, required: true, validator: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _checkRow('Show history', _showHistory, (v) => setState(() => _showHistory = v)),

        // Factor + Decimal precision
        _doubleRow('Factor', _factorCtrl, 'Decimal precision',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Decimal precision', style: TextStyle(fontSize: 15, color: Colors.black87)),
              TextFormField(controller: _decimalPrecisionCtrl, keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
            ])),

        // Unit + Text size
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Unit', style: TextStyle(fontSize: 15, color: Colors.black87)),
              TextFormField(controller: _unitCtrl, style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
            ])),
            const SizedBox(width: 24),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Text size', style: TextStyle(fontSize: 13, color: Colors.black54)),
              DropdownButtonFormField<String>(value: _textSize,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26))),
                  items: _textSizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _textSize = v!)),
            ])),
          ])),
          _divider(),
        ]),

        _checkRow('Digital font', _digitalFont, (v) => setState(() => _digitalFont = v)),
        _checkRow('Hide topic', _hideTopic, (v) => setState(() => _hideTopic = v)),
        _checkRow('Enable notification or alarm', _enableNotification, (v) => setState(() => _enableNotification = v), showHelp: true, enabled: false),
        _checkRow('Payload is JSON Data', _payloadIsJson, (v) => setState(() => _payloadIsJson = v)),
        _checkRow('Show received timestamp', _showReceivedTimestamp, (v) => setState(() => _showReceivedTimestamp = v)),

        // QoS only (no retain for text output)
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
          _divider(),
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