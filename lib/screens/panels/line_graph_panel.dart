import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddLineGraphPanelScreen extends StatefulWidget {
  const AddLineGraphPanelScreen({super.key});

  @override
  State<AddLineGraphPanelScreen> createState() =>
      _AddLineGraphPanelScreenState();
}

class _AddLineGraphPanelScreenState extends State<AddLineGraphPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _maxPersistenceCtrl = TextEditingController(text: '10');
  final _unitCtrl = TextEditingController();

  IconData _panelIcon = Icons.widgets_outlined;

  bool _disableDashboardPrefix = false;
  bool _showPlotArea = false;
  bool _showPointsAndTooltip = false;
  bool _enableNotification = false;
  bool _payloadIsJson = false;
  bool _smoothCurve = false;
  bool _retain = false;
  String _maxDuration = 'None';
  int _qos = 0;

  final List<String> _durations = [
    'None',
    '1 min',
    '5 min',
    '10 min',
    '30 min',
    '1 hour',
    '6 hours',
    '1 day',
  ];
  final List<int> _qosOptions = [0, 1, 2];

  // Graph series - each has topic, label, factor, decimalPrecision, color
  final List<Map<String, dynamic>> _graphs = [];
  final List<Color> _defaultColors = [
    const Color(0xFFEA1111),
    Colors.green,
    const Color(0xFF1E88E5),
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _addGraph();
  }

  void _addGraph() {
    final idx = _graphs.length;
    _graphs.add({
      'topic': TextEditingController(),
      'label': TextEditingController(),
      'factor': TextEditingController(text: '1'),
      'decimalPrecision': TextEditingController(),
      'color': _defaultColors[idx % _defaultColors.length],
      'enableNotif': false,
      'payloadIsJson': false,
    });
  }

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    _maxPersistenceCtrl.dispose();
    _unitCtrl.dispose();
    for (final g in _graphs) {
      (g['topic'] as TextEditingController).dispose();
      (g['label'] as TextEditingController).dispose();
      (g['factor'] as TextEditingController).dispose();
      (g['decimalPrecision'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _pickGraphColor(int idx) {
    final colors = [
      const Color(0xFFEA1111),
      Colors.green,
      const Color(0xFF1E88E5),
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Graph Color'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() => _graphs[idx]['color'] = c);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (_graphs[idx]['color'] as Color) == c
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Line Graph',
        'label': _panelNameCtrl.text.trim(),
        'graphs': _graphs
            .map(
              (g) => {
                'topic': (g['topic'] as TextEditingController).text.trim(),
                'label': (g['label'] as TextEditingController).text.trim(),
                'icon': iconToString(_panelIcon),
                'factor': (g['factor'] as TextEditingController).text.trim(),
                'color': (g['color'] as Color).value.toString(),
              },
            )
            .toList(),
        'smoothCurve': _smoothCurve,
        'maxPersistence': _maxPersistenceCtrl.text.trim(),
        'maxDuration': _maxDuration,
        'qos': _qos,
      });
    }
  }

  Widget _d() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

  Widget _help() => Container(
    width: 28,
    height: 28,
    decoration: const BoxDecoration(
      color: Color(0xFF1E88E5),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.question_mark, color: Colors.white, size: 15),
  );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool req = false,
    bool showHelp = false,
    String? Function(String?)? val,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: label,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        children: req
                            ? const [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ]
                            : [],
                      ),
                    ),
                    TextFormField(
                      controller: ctrl,
                      validator: val,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.only(top: 6, bottom: 8),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1E88E5)),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showHelp)
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 8),
                  child: _help(),
                ),
            ],
          ),
        ),
        _d(),
      ],
    );
  }

  Widget _check(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool help = false,
    bool enabled = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: enabled ? () => onChanged(!value) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    value: value,
                    onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(
                      color: enabled ? Colors.black54 : Colors.black26,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      color: enabled ? Colors.black87 : Colors.black38,
                    ),
                  ),
                ),
                if (help) _help(),
              ],
            ),
          ),
        ),
        _d(),
      ],
    );
  }

  // Graph series block
  Widget _graphBlock(int idx, AppLocalizations l) {
    final g = _graphs[idx];
    final color = g['color'] as Color;
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dynamic header for each series
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            '${l.graphSeries} ${idx + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E88E5),
            ),
          ),
        ),

        _field(
          '${l.topicForGraph} ${idx + 1}',
          g['topic'] as TextEditingController,
          req: true,
          val: (v) => (v == null || v.isEmpty) ? l.required : null,
        ),

        _field(
          '${l.labelForGraph} ${idx + 1}',
          g['label'] as TextEditingController,
        ),

        // Factor + Decimal precision
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.factor,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        TextFormField(
                          controller: g['factor'] as TextEditingController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 15),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.decimal,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        TextFormField(
                          controller:
                              g['decimalPrecision'] as TextEditingController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 15),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _d(),
          ],
        ),

        // Graph color row
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickGraphColor(idx),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.graphColor,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          hex,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _d(),
          ],
        ),

        _check(
          l.payloadIsJson,
          g['payloadIsJson'] as bool,
          (v) => setState(() => g['payloadIsJson'] = v),
        ),

        // Add a small spacer or a subtle background change if you have many series
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context.watch<AppSettings>().languageCode);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.addLineGraphPanel,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            _field(
              l.panelName,
              _panelNameCtrl,
              req: true,
              val: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _check(
              l.disableDashboardPrefix,
              _disableDashboardPrefix,
              (v) => setState(() => _disableDashboardPrefix = v),
            ),
            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            // Localized Graph Series Blocks
            ...List.generate(_graphs.length, (i) => _graphBlock(i, l)),

            // Add more graph series
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.addMoreGraph,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _addGraph()),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _d(),
              ],
            ),

            _check(
              l.smoothCurve,
              _smoothCurve,
              (v) => setState(() => _smoothCurve = v),
              help: true,
            ),

            // Max Persistence Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.maxPersistence,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            TextFormField(
                              controller: _maxPersistenceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(isDense: true),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 8),
                        child: _help(),
                      ),
                    ],
                  ),
                ),
                _d(),
              ],
            ),

            // Max Duration Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.maxDuration,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _maxDuration,
                              items: _durations
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _maxDuration = v!),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 8),
                        child: _help(),
                      ),
                    ],
                  ),
                ),
                _d(),
              ],
            ),

            // Retain & QoS Row
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _retain,
                        onChanged: (v) => setState(() => _retain = v ?? false),
                      ),
                      Text(l.retain),
                      const Spacer(),
                      const Text('QoS'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _qos,
                        items: _qosOptions
                            .map(
                              (q) =>
                                  DropdownMenuItem(value: q, child: Text('$q')),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _qos = v!),
                      ),
                    ],
                  ),
                ),
                _d(),
              ],
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 130,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                      ),
                      onPressed: _create,
                      child: Text(
                        l.create,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
