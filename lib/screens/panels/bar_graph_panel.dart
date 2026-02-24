import 'package:flutter/material.dart';

class AddBarGraphPanelScreen extends StatefulWidget {
  const AddBarGraphPanelScreen({super.key});
  @override
  State<AddBarGraphPanelScreen> createState() => _AddBarGraphPanelScreenState();
}

class _AddBarGraphPanelScreenState extends State<AddBarGraphPanelScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _unitCtrl      = TextEditingController();

  bool   _disableDashboardPrefix = false;
  bool   _defineRange            = false;
  bool   _retain                 = false;
  String _orientation            = 'Vertical';
  int    _qos                    = 0;

  final List<String> _orientations = ['Vertical', 'Horizontal'];
  final List<int>    _qosOptions   = [0, 1, 2];
  final List<Color>  _defaultColors = [const Color(0xFFEA1111), Colors.green, const Color(0xFF1E88E5), Colors.orange, Colors.purple];

  final List<Map<String, dynamic>> _bars = [];

  @override
  void initState() { super.initState(); _addBar(); }

  void _addBar() {
    final idx = _bars.length;
    _bars.add({
      'topic':            TextEditingController(),
      'label':            TextEditingController(),
      'factor':           TextEditingController(text: '1'),
      'decimalPrecision': TextEditingController(),
      'color':            _defaultColors[idx % _defaultColors.length],
      'enableNotif':      false,
      'payloadIsJson':    false,
    });
  }

  @override
  void dispose() {
    _panelNameCtrl.dispose(); _unitCtrl.dispose();
    for (final b in _bars) {
      (b['topic'] as TextEditingController).dispose();
      (b['label'] as TextEditingController).dispose();
      (b['factor'] as TextEditingController).dispose();
      (b['decimalPrecision'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _pickBarColor(int idx) {
    final colors = [const Color(0xFFEA1111), Colors.green, const Color(0xFF1E88E5), Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo];
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Pick Bar Color'),
      content: Wrap(spacing: 10, runSpacing: 10, children: colors.map((c) => GestureDetector(
        onTap: () { setState(() => _bars[idx]['color'] = c); Navigator.pop(context); },
        child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c, shape: BoxShape.circle,
            border: Border.all(color: (_bars[idx]['color'] as Color) == c ? Colors.black : Colors.transparent, width: 3))),
      )).toList()),
    ));
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Bar Graph', 'label': _panelNameCtrl.text.trim(),
        'bars': _bars.map((b) => {
          'topic': (b['topic'] as TextEditingController).text.trim(),
          'label': (b['label'] as TextEditingController).text.trim(),
          'factor': (b['factor'] as TextEditingController).text.trim(),
          'color': (b['color'] as Color).value.toString(),
        }).toList(),
        'defineRange': _defineRange, 'unit': _unitCtrl.text.trim(),
        'orientation': _orientation, 'qos': _qos,
      });
    }
  }

  Widget _d() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));
  Widget _help() => Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle), child: const Icon(Icons.question_mark, color: Colors.white, size: 15));

  Widget _field(String label, TextEditingController ctrl, {bool req = false, String? Function(String?)? val}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(text: TextSpan(text: label, style: const TextStyle(fontSize: 15, color: Colors.black87),
            children: req ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [])),
        TextFormField(controller: ctrl, validator: val, style: const TextStyle(fontSize: 15, color: Colors.black87),
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))),
                errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)))),
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

  Widget _barBlock(int idx) {
    final b = _bars[idx];
    final color = b['color'] as Color;
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _field('Topic for bar ${idx + 1}', b['topic'] as TextEditingController, req: true, val: (v) => (v==null||v.isEmpty) ? 'Required' : null),
      _field('Label for bar ${idx + 1}', b['label'] as TextEditingController),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Factor', style: TextStyle(fontSize: 13, color: Colors.black54)),
            TextFormField(controller: b['factor'] as TextEditingController, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
          ])),
          const SizedBox(width: 24),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Decimal precision', style: TextStyle(fontSize: 15, color: Colors.black87)),
            TextFormField(controller: b['decimalPrecision'] as TextEditingController, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
          ])),
        ])),
        _d(),
      ]),
      Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: Row(children: [
          GestureDetector(onTap: () => _pickBarColor(idx),
              child: Container(width: 36, height: 36, decoration: BoxDecoration(color: color, shape: BoxShape.circle))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bar color', style: TextStyle(fontSize: 13, color: Colors.black54)),
            Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black26))),
                child: Text(hex, style: const TextStyle(fontSize: 15, color: Colors.black87))),
          ])),
        ])),
        _d(),
      ]),
      _check('Enable notification or alarm', b['enableNotif'] as bool, (v) => setState(() => b['enableNotif'] = v), help: true, enabled: false),
      _check('Payload is JSON Data', b['payloadIsJson'] as bool, (v) => setState(() => b['payloadIsJson'] = v)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: const Text('Add a Bar Graph panel', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade300, height: 1))),
      body: Form(key: _formKey, child: ListView(children: [
        _field('Panel name', _panelNameCtrl, req: true, val: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _check('Disable dashboard prefix topic', _disableDashboardPrefix, (v) => setState(() => _disableDashboardPrefix = v)),
        ...List.generate(_bars.length, (i) => _barBlock(i)),
        Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Add more bar', style: TextStyle(fontSize: 15, color: Colors.black87)),
            GestureDetector(onTap: () => setState(() => _addBar()),
                child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 26))),
          ])),
          _d(),
        ]),
        _check('Define range', _defineRange, (v) => setState(() => _defineRange = v)),
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
              const Text('Orientation', style: TextStyle(fontSize: 13, color: Colors.black54)),
              DropdownButtonFormField<String>(value: _orientation, style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26))),
                  items: _orientations.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (v) => setState(() => _orientation = v!)),
            ])),
          ])),
          _d(),
        ]),
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