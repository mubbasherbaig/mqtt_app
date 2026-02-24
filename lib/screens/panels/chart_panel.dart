import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../app_settings.dart';

class AddChartPanelScreen extends StatefulWidget {
  const AddChartPanelScreen({super.key});

  @override
  State<AddChartPanelScreen> createState() => _AddChartPanelScreenState();
}

class _AddChartPanelScreenState extends State<AddChartPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();

  bool _disableDashboardPrefix = false;
  String _chartType = 'Pie chart';
  int _qos = 0;

  final List<int> _qosOptions = [0, 1, 2];
  final List<Color> _defaultColors = [
    const Color(0xFFEA1111),
    const Color(0xFF2FCB11),
    const Color(0xFF1E88E5),
    Colors.orange,
    Colors.purple
  ];

  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _addItem(); // Start with one item
  }

  void _addItem() {
    final idx = _items.length;
    setState(() {
      _items.add({
        'topic': TextEditingController(),
        'label': TextEditingController(),
        'factor': TextEditingController(text: '1'),
        'decimalPrecision': TextEditingController(text: '0'),
        'color': _defaultColors[idx % _defaultColors.length],
        'payloadIsJson': false,
      });
    });
  }

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    _unitCtrl.dispose();
    for (final item in _items) {
      (item['topic'] as TextEditingController).dispose();
      (item['label'] as TextEditingController).dispose();
      (item['factor'] as TextEditingController).dispose();
      (item['decimalPrecision'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _pickColor(int idx, AppLocalizations l) {
    final colors = [
      const Color(0xFFEA1111), const Color(0xFF2FCB11), const Color(0xFF1E88E5),
      Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.buttonColor), // Reusing color picker title
        content: Wrap(
          spacing: 10, runSpacing: 10,
          children: colors.map((c) => GestureDetector(
            onTap: () {
              setState(() => _items[idx]['color'] = c);
              Navigator.pop(context);
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c, shape: BoxShape.circle,
                border: Border.all(
                  color: (_items[idx]['color'] as Color) == c ? Colors.black : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Chart',
        'label': _panelNameCtrl.text.trim(),
        'chartType': _chartType,
        'unit': _unitCtrl.text.trim(),
        'disableDashboardPrefix': _disableDashboardPrefix,
        'items': _items.map((i) => {
          'topic': (i['topic'] as TextEditingController).text.trim(),
          'label': (i['label'] as TextEditingController).text.trim(),
          'factor': (i['factor'] as TextEditingController).text.trim(),
          'decimalPrecision': (i['decimalPrecision'] as TextEditingController).text.trim(),
          'color': (i['color'] as Color).value.toString(),
          'payloadIsJson': i['payloadIsJson'],
        }).toList(),
        'qos': _qos,
      });
    }
  }

  // --- Reusable UI Parts ---
  Widget _d() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

  Widget _help() => Container(
    width: 28, height: 28,
    decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
    child: const Icon(Icons.question_mark, color: Colors.white, size: 15),
  );

  Widget _field(String label, TextEditingController ctrl, {bool req = false, String? Function(String?)? val}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(text: TextSpan(
                  text: label,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  children: req ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [])
              ),
              TextFormField(
                controller: ctrl, validator: val,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: const InputDecoration(
                  isDense: true, contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
        _d(),
      ],
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged, {bool help = false}) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 28, height: 28, child: Checkbox(
                  value: value, onChanged: (v) => onChanged(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Colors.black54, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87))),
                if (help) _help(),
              ],
            ),
          ),
        ),
        _d(),
      ],
    );
  }

  Widget _itemBlock(int idx, AppLocalizations l) {
    final item = _items[idx];
    final color = item['color'] as Color;
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('${l.topic} (${l.item} ${idx + 1})', item['topic'] as TextEditingController, req: true, val: (v) => (v==null||v.isEmpty) ? l.required : null),
          _field('${l.label} (${l.item} ${idx + 1})', item['label'] as TextEditingController),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.factor, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    TextFormField(
                      controller: item['factor'] as TextEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                    ),
                  ],
                )),
                const SizedBox(width: 20),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.decimal, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    TextFormField(
                      controller: item['decimalPrecision'] as TextEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                    ),
                  ],
                )),
              ],
            ),
          ),
          _d(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _pickColor(idx, l),
                  child: Container(width: 36, height: 36, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 12),
                Text('${l.buttonColor}: $hex', style: const TextStyle(fontSize: 15)),
                const Spacer(),
                if (_items.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => setState(() => _items.removeAt(idx)),
                  )
              ],
            ),
          ),
          _check(l.payloadIsJson, item['payloadIsJson'] as bool, (v) => setState(() => item['payloadIsJson'] = v)),
          Container(height: 10, color: Colors.white), // Spacer between items
          _d(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context.watch<AppSettings>().languageCode);
    final chartTypesMap = {
      'Pie chart': l.pieChart,
      'Donut chart': l.donutChart,
      'Bar chart': l.barChart,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(l.addChartPanel, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade300, height: 1)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            _field(l.panelName, _panelNameCtrl, req: true, val: (v) => (v==null||v.isEmpty) ? l.required : null),
            _check(l.disableDashboardPrefix, _disableDashboardPrefix, (v) => setState(() => _disableDashboardPrefix = v), help: true),

            ...List.generate(_items.length, (i) => _itemBlock(i, l)),

            // Add Item Button
            InkWell(
              onTap: _addItem,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 10),
                    Text(l.addMoreItem, style: const TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            _d(),

            // Unit and Type
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _field(l.unit, _unitCtrl)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _chartType,
                      decoration: InputDecoration(labelText: l.chartType),
                      items: chartTypesMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                      onChanged: (v) => setState(() => _chartType = v!),
                    ),
                  ),
                ],
              ),
            ),

            // QoS Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('QoS: '),
                  DropdownButton<int>(
                    value: _qos,
                    items: _qosOptions.map((q) => DropdownMenuItem(value: q, child: Text('$q'))).toList(),
                    onChanged: (v) => setState(() => _qos = v!),
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel))),
                  const SizedBox(width: 16),
                  Expanded(child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
                      onPressed: _create, child: Text(l.create, style: const TextStyle(color: Colors.white)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}