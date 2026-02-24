import 'package:flutter/material.dart';

class AddLineGraphPanelScreen extends StatefulWidget {
  const AddLineGraphPanelScreen({super.key});
  @override
  State<AddLineGraphPanelScreen> createState() => _AddLineGraphPanelScreenState();
}

class _AddLineGraphPanelScreenState extends State<AddLineGraphPanelScreen> {
  final _formKey              = GlobalKey<FormState>();
  final _panelNameCtrl        = TextEditingController();
  final _maxPersistenceCtrl   = TextEditingController(text: '10');
  final _unitCtrl             = TextEditingController();

  bool   _disableDashboardPrefix = false;
  bool   _showPlotArea           = false;
  bool   _showPointsAndTooltip   = false;
  bool   _enableNotification     = false;
  bool   _payloadIsJson          = false;
  bool   _smoothCurve            = false;
  bool   _retain                 = false;
  String _maxDuration            = 'None';
  int    _qos                    = 0;

  final List<String> _durations  = ['None', '1 min', '5 min', '10 min', '30 min', '1 hour', '6 hours', '1 day'];
  final List<int>    _qosOptions = [0, 1, 2];

  // Graph series - each has topic, label, factor, decimalPrecision, color
  final List<Map<String, dynamic>> _graphs = [];
  final List<Color> _defaultColors = [const Color(0xFFEA1111), Colors.green, const Color(0xFF1E88E5), Colors.orange, Colors.purple];

  @override
  void initState() {
    super.initState();
    _addGraph();
  }

  void _addGraph() {
    final idx = _graphs.length;
    _graphs.add({
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
    _panelNameCtrl.dispose(); _maxPersistenceCtrl.dispose(); _unitCtrl.dispose();
    for (final g in _graphs) {
      (g['topic'] as TextEditingController).dispose();
      (g['label'] as TextEditingController).dispose();
      (g['factor'] as TextEditingController).dispose();
      (g['decimalPrecision'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _pickGraphColor(int idx) {
    final colors = [const Color(0xFFEA1111), Colors.green, const Color(0xFF1E88E5), Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo];
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Pick Graph Color'),
      content: Wrap(spacing: 10, runSpacing: 10, children: colors.map((c) => GestureDetector(
        onTap: () { setState(() => _graphs[idx]['color'] = c); Navigator.pop(context); },
        child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c, shape: BoxShape.circle,
            border: Border.all(color: (_graphs[idx]['color'] as Color) == c ? Colors.black : Colors.transparent, width: 3))),
      )).toList()),
    ));
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Line Graph', 'label': _panelNameCtrl.text.trim(),
        'graphs': _graphs.map((g) => {
          'topic': (g['topic'] as TextEditingController).text.trim(),
          'label': (g['label'] as TextEditingController).text.trim(),
          'factor': (g['factor'] as TextEditingController).text.trim(),
          'color': (g['color'] as Color).value.toString(),
        }).toList(),
        'smoothCurve': _smoothCurve, 'maxPersistence': _maxPersistenceCtrl.text.trim(),
        'maxDuration': _maxDuration, 'qos': _qos,
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

  // Graph series block
  Widget _graphBlock(int idx) {
    final g = _graphs[idx];
    final color = g['color'] as Color;
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _field('Topic for graph ${idx + 1}', g['topic'] as TextEditingController, req: true, val: (v) => (v==null||v.isEmpty) ? 'Required' : null),
      _field('Label for graph ${idx + 1}', g['label'] as TextEditingController),
      // Factor + Decimal precision
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Factor', style: TextStyle(fontSize: 13, color: Colors.black54)),
            TextFormField(controller: g['factor'] as TextEditingController, keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
          ])),
          const SizedBox(width: 24),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Decimal precision', style: TextStyle(fontSize: 15, color: Colors.black87)),
            TextFormField(controller: g['decimalPrecision'] as TextEditingController, keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
          ])),
        ])),
        _d(),
      ]),
      // Graph color row
      Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: Row(children: [
          GestureDetector(onTap: () => _pickGraphColor(idx),
              child: Container(width: 36, height: 36, decoration: BoxDecoration(color: color, shape: BoxShape.circle))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Graph color', style: TextStyle(fontSize: 13, color: Colors.black54)),
            Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black26))),
                child: Text(hex, style: const TextStyle(fontSize: 15, color: Colors.black87))),
          ])),
        ])),
        _d(),
      ]),
      _check('Show plot area', _showPlotArea, (v) => setState(() => _showPlotArea = v)),
      // Show points + Unit on same row
      Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(children: [
          SizedBox(width: 28, height: 28, child: Checkbox(value: _showPointsAndTooltip,
              onChanged: (v) => setState(() => _showPointsAndTooltip = v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: Colors.black54, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)))),
          const SizedBox(width: 12),
          const Text('Show points and tooltip', style: TextStyle(fontSize: 15, color: Colors.black87)),
          const Spacer(),
          SizedBox(width: 80, child: TextField(controller: _unitCtrl,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(labelText: 'Unit', labelStyle: TextStyle(fontSize: 14),
                  isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5)))))),
        ])),
        _d(),
      ]),
      _check('Enable notification or alarm', g['enableNotif'] as bool,
              (v) => setState(() => g['enableNotif'] = v), help: true, enabled: false),
      _check('Payload is JSON Data', g['payloadIsJson'] as bool,
              (v) => setState(() => g['payloadIsJson'] = v)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: const Text('Add a Line Graph panel', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade300, height: 1))),
      body: Form(key: _formKey, child: ListView(children: [
        _field('Panel name', _panelNameCtrl, req: true, val: (v) => (v==null||v.isEmpty) ? 'Required' : null),
        _check('Disable dashboard prefix topic', _disableDashboardPrefix, (v) => setState(() => _disableDashboardPrefix = v)),
        ...List.generate(_graphs.length, (i) => _graphBlock(i)),
        // Add more graph
        Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Add more graph', style: TextStyle(fontSize: 15, color: Colors.black87)),
            GestureDetector(onTap: () => setState(() => _addGraph()),
                child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 26))),
          ])),
          _d(),
        ]),
        _check('Smooth curve', _smoothCurve, (v) => setState(() => _smoothCurve = v), help: true),
        // Max persistence
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Max persistence', style: TextStyle(fontSize: 13, color: Colors.black54)),
              TextFormField(controller: _maxPersistenceCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))))),
            ])),
            Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: _help()),
          ])),
          _d(),
        ]),
        // Max duration
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 0), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Max duration', style: TextStyle(fontSize: 13, color: Colors.black54)),
              DropdownButtonFormField<String>(value: _maxDuration, style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26))),
                  items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => _maxDuration = v!)),
            ])),
            Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: _help()),
          ])),
          _d(),
        ]),
        Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Row(children: [
            SizedBox(width: 28, height: 28, child: Checkbox(value: _retain, onChanged: (v) => setState(() => _retain = v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: const BorderSide(color: Colors.black54, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 12),
            const Text('Retain', style: TextStyle(fontSize: 15, color: Colors.black87)),
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