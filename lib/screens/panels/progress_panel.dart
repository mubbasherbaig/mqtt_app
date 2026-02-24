import 'package:flutter/material.dart';

class AddProgressPanelScreen extends StatefulWidget {
  const AddProgressPanelScreen({super.key});
  @override
  State<AddProgressPanelScreen> createState() => _AddProgressPanelScreenState();
}

class _AddProgressPanelScreenState extends State<AddProgressPanelScreen> {
  final _formKey              = GlobalKey<FormState>();
  final _panelNameCtrl        = TextEditingController();
  final _topicCtrl            = TextEditingController();
  final _payloadMinCtrl       = TextEditingController();
  final _payloadMaxCtrl       = TextEditingController();
  final _factorCtrl           = TextEditingController(text: '1');
  final _decimalPrecisionCtrl = TextEditingController();
  final _unitCtrl             = TextEditingController();

  bool   _disableDashboardPrefix = false;
  bool   _dynamicColor           = false;
  bool   _enableNotification     = false;
  bool   _payloadIsJson          = false;
  bool   _showReceivedTimestamp  = false;

  Color  _color         = const Color(0xFF1E88E5);
  String _progressType  = 'Horizontal';
  int    _qos           = 0;

  final List<String> _progressTypes = ['Horizontal', 'Vertical', 'Circular'];
  final List<int>    _qosOptions    = [0, 1, 2];

  @override
  void dispose() { _panelNameCtrl.dispose(); _topicCtrl.dispose(); _payloadMinCtrl.dispose(); _payloadMaxCtrl.dispose(); _factorCtrl.dispose(); _decimalPrecisionCtrl.dispose(); _unitCtrl.dispose(); super.dispose(); }

  void _pickColor() {
    final colors = [const Color(0xFF1E88E5), Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo];
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Pick Color'),
      content: Wrap(spacing: 10, runSpacing: 10, children: colors.map((c) => GestureDetector(
        onTap: () { setState(() => _color = c); Navigator.pop(context); },
        child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c, shape: BoxShape.circle,
            border: Border.all(color: _color == c ? Colors.black : Colors.transparent, width: 3))),
      )).toList()),
    ));
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Progress', 'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(), 'payloadMin': _payloadMinCtrl.text.trim(),
        'payloadMax': _payloadMaxCtrl.text.trim(), 'factor': _factorCtrl.text.trim(),
        'decimalPrecision': _decimalPrecisionCtrl.text.trim(), 'unit': _unitCtrl.text.trim(),
        'progressType': _progressType, 'color': _color.value.toString(), 'qos': _qos,
      });
    }
  }

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));
  Widget _helpIcon() => Container(width: 28, height: 28,
      decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
      child: const Icon(Icons.question_mark, color: Colors.white, size: 15));

  Widget _fieldRow(String label, TextEditingController ctrl, {bool required = false, bool showHelp = false, String? Function(String?)? validator, TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          RichText(text: TextSpan(text: label, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
              children: required ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [])),
          TextFormField(controller: ctrl, validator: validator, keyboardType: keyboardType, style: const TextStyle(fontSize: 15, color: Colors.black87),
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

  Widget _doubleFieldRow(String l1, TextEditingController c1, bool r1, String l2, TextEditingController c2, bool r2, {String? Function(String?)? v1, String? Function(String?)? v2}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(text: TextSpan(text: l1, style: const TextStyle(fontSize: 15, color: Colors.black87),
              children: r1 ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [])),
          TextFormField(controller: c1, validator: v1, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)))),
        ])),
        const SizedBox(width: 24),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(text: TextSpan(text: l2, style: const TextStyle(fontSize: 15, color: Colors.black87),
              children: r2 ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [])),
          TextFormField(controller: c2, validator: v2, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)))),
        ])),
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
          title: const Text('Add a Progress panel', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade300, height: 1))),
      body: Form(key: _formKey, child: ListView(children: [
        _fieldRow('Panel name', _panelNameCtrl, required: true, validator: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _checkRow('Disable dashboard prefix topic', _disableDashboardPrefix, (v) => setState(() => _disableDashboardPrefix = v), showHelp: true),
        _fieldRow('Topic', _topicCtrl, required: true, validator: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _doubleFieldRow('Payload min', _payloadMinCtrl, true, 'Payload max', _payloadMaxCtrl, true,
            v1: (v) => (v==null||v.isEmpty) ? 'Required' : null, v2: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _doubleFieldRow('Factor', _factorCtrl, false, 'Decimal precision', _decimalPrecisionCtrl, false),
        // Unit + Progress type
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Unit', style: TextStyle(fontSize: 15, color: Colors.black87)),
              TextFormField(controller: _unitCtrl, style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
            ])),
            const SizedBox(width: 24),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Progress type', style: TextStyle(fontSize: 13, color: Colors.black54)),
              DropdownButtonFormField<String>(value: _progressType,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26))),
                  items: _progressTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _progressType = v!)),
            ])),
          ])),
          _divider(),
        ]),
        // Color
        Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Color', style: TextStyle(fontSize: 15, color: Colors.black87)),
            GestureDetector(onTap: _pickColor, child: Container(width: 110, height: 36,
                decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(4)),
                alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 8),
                child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 22))),
          ])),
          _divider(),
        ]),
        _checkRow('Dynamic color', _dynamicColor, (v) => setState(() => _dynamicColor = v)),
        _checkRow('Enable notification or alarm', _enableNotification, (v) => setState(() => _enableNotification = v), showHelp: true, enabled: _dynamicColor),
        _checkRow('Payload is JSON Data', _payloadIsJson, (v) => setState(() => _payloadIsJson = v)),
        _checkRow('Show received timestamp', _showReceivedTimestamp, (v) => setState(() => _showReceivedTimestamp = v)),
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