import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddProgressPanelScreen extends StatefulWidget {
  const AddProgressPanelScreen({super.key, this.initialData});
  final Map<String, dynamic>? initialData;
  @override
  State<AddProgressPanelScreen> createState() => _AddProgressPanelScreenState();
}

class _AddProgressPanelScreenState extends State<AddProgressPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();
  final _payloadMinCtrl = TextEditingController();
  final _payloadMaxCtrl = TextEditingController();
  final _factorCtrl = TextEditingController(text: '1');
  final _decimalPrecisionCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  bool get _isEditing => widget.initialData != null;

  IconData _panelIcon = Icons.widgets_outlined;

  bool _disableDashboardPrefix = true;
  bool _dynamicColor = false;
  bool _enableNotification = false;
  bool _payloadIsJson = false;
  bool _showReceivedTimestamp = false;

  Color _color = const Color(0xFF1E88E5);
  String _progressType = 'Horizontal';
  int _qos = 0;

  final List<String> _progressTypes = ['Horizontal', 'Vertical', 'Circular'];
  final List<int> _qosOptions = [0, 1, 2];

  final _jsonPathCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _panelNameCtrl.text = d['label'] as String? ?? d['panelName'] as String? ?? '';
      _topicCtrl.text = d['topic'] as String? ?? '';
      _payloadMinCtrl.text = d['payloadMin']?.toString() ?? '';
      _payloadMaxCtrl.text = d['payloadMax']?.toString() ?? '';
      _factorCtrl.text = d['factor']?.toString() ?? '1';
      _decimalPrecisionCtrl.text = d['decimalPrecision']?.toString() ?? '';
      _unitCtrl.text = d['unit'] as String? ?? '';
      _disableDashboardPrefix = d['disableDashboardPrefix'] == true;
      _dynamicColor = d['dynamicColor'] == true;
      _payloadIsJson = d['payloadIsJson'] == true;
      _showReceivedTimestamp = d['showReceivedTimestamp'] == true;
      _progressType = d['progressType'] as String? ?? 'Horizontal';
      _qos = int.tryParse(d['qos']?.toString() ?? '0') ?? 0;
      final colorVal = int.tryParse(d['color']?.toString() ?? '');
      if (colorVal != null) _color = Color(colorVal);
      final iconStr = d['icon'] as String?;
      if (iconStr != null) _panelIcon = iconFromString(iconStr) ?? Icons.widgets_outlined;
      _jsonPathCtrl.text    = d['jsonPath'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    _topicCtrl.dispose();
    _payloadMinCtrl.dispose();
    _payloadMaxCtrl.dispose();
    _factorCtrl.dispose();
    _decimalPrecisionCtrl.dispose();
    _unitCtrl.dispose();
    _jsonPathCtrl.dispose();
    super.dispose();
  }

  void _pickColor() {
    final colors = [
      const Color(0xFF1E88E5),
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Color'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() => _color = c);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == c ? Colors.black : Colors.transparent,
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
        'type': 'Progress',
        'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(),
        'payloadMin': _payloadMinCtrl.text.trim(),
        'payloadMax': _payloadMaxCtrl.text.trim(),
        'factor': _factorCtrl.text.trim(),
        'decimalPrecision': _decimalPrecisionCtrl.text.trim(),
        'unit': _unitCtrl.text.trim(),
        'progressType': _progressType,
        'icon': iconToString(_panelIcon),
        'color': _color.value.toString(),
        'qos': _qos,
        'disableDashboardPrefix': _disableDashboardPrefix,
        'dynamicColor': _dynamicColor,
        'payloadIsJson': _payloadIsJson,
        'showReceivedTimestamp': _showReceivedTimestamp,
        'jsonPath':    _jsonPathCtrl.text.trim(),

      });
    }
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

  Widget _helpIcon() => Container(
    width: 28,
    height: 28,
    decoration: const BoxDecoration(
      color: Color(0xFF1E88E5),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.question_mark, color: Colors.white, size: 15),
  );

  Widget _fieldRow(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    bool showHelp = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: label,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                        children: required
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
                      validator: validator,
                      keyboardType: keyboardType,
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
                  child: _helpIcon(),
                ),
            ],
          ),
        ),
        _divider(),
      ],
    );
  }

  Widget _doubleFieldRow(
    String l1,
    TextEditingController c1,
    bool r1,
    String l2,
    TextEditingController c2,
    bool r2, {
    String? Function(String?)? v1,
    String? Function(String?)? v2,
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
                        text: l1,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        children: r1
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
                      controller: c1,
                      validator: v1,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15),
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
                    RichText(
                      text: TextSpan(
                        text: l2,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        children: r2
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
                      controller: c2,
                      validator: v2,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15),
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _divider(),
      ],
    );
  }

  Widget _checkRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool showHelp = false,
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
                if (showHelp) _helpIcon(),
              ],
            ),
          ),
        ),
        _divider(),
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
          _isEditing ? l.edit : l.addProgressPanel,
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
            _fieldRow(
              l.panelName,
              _panelNameCtrl,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _checkRow(
              l.disableDashboardPrefix,
              _disableDashboardPrefix,
              (v) => setState(() => _disableDashboardPrefix = v),
              showHelp: true,
            ),
            _fieldRow(
              l.topic,
              _topicCtrl,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            _divider(),
            _doubleFieldRow(
              l.payloadMin,
              _payloadMinCtrl,
              true,
              l.payloadMax,
              _payloadMaxCtrl,
              true,
              v1: (v) => (v == null || v.isEmpty) ? l.required : null,
              v2: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),

            _doubleFieldRow(
              l.factor,
              _factorCtrl,
              false,
              l.decimal,
              _decimalPrecisionCtrl,
              false,
            ),

            // Unit + Progress type
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
                              l.unit,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            TextFormField(
                              controller: _unitCtrl,
                              style: const TextStyle(fontSize: 15),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: 6,
                                  bottom: 8,
                                ),
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
                              l.progressType,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _progressType,
                              items: _progressTypes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(l.get(t)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _progressType = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ],
            ),

            // Color Section
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
                        l.color,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickColor,
                        child: Container(
                          width: 110,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ],
            ),

            _checkRow(
              l.dynamicColor,
              _dynamicColor,
              (v) => setState(() => _dynamicColor = v),
            ),
            _checkRow(
              l.payloadIsJson,
              _payloadIsJson,
              (v) => setState(() => _payloadIsJson = v),
            ),
            if (_payloadIsJson) ...[
              _fieldRow(l.jsonPath, _jsonPathCtrl, showHelp: true),
            ],
            _checkRow(
              l.showReceivedTimestamp,
              _showReceivedTimestamp,
              (v) => setState(() => _showReceivedTimestamp = v),
            ),

            // Footer Actions
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
                        _isEditing ? l.save : l.create,
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
