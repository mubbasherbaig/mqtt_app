import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddDateTimePickerPanelScreen extends StatefulWidget {
  const AddDateTimePickerPanelScreen({super.key, this.initialData});
  final Map<String, dynamic>? initialData;
  @override
  State<AddDateTimePickerPanelScreen> createState() =>
      _AddDateTimePickerPanelScreenState();
}

class _AddDateTimePickerPanelScreenState
    extends State<AddDateTimePickerPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();

  final _subscribeTopicCtrl = TextEditingController();
  IconData _panelIcon = Icons.widgets_outlined;
  bool _disableDashboardPrefix = true;
  bool _payloadIsJson = false;
  bool _showSentTimestamp = false;
  bool _retain = false;
  Color _buttonColor = const Color(0xFF1E88E5);
  String _pickerType = 'Date Time';
  String _buttonSize = 'Medium';
  int _qos = 0;

  bool get _isEditing => widget.initialData != null;

  final List<String> _pickerTypes = ['Date Time', 'Date', 'Time'];
  final List<String> _buttonSizes = ['Small', 'Medium', 'Large'];
  final List<int> _qosOptions = [0, 1, 2];

  final _jsonPathCtrl    = TextEditingController();
  final _jsonPatternCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _panelNameCtrl.text = d['label'] as String? ?? d['panelName'] as String? ?? '';
      _topicCtrl.text = d['topic'] as String? ?? '';
      _disableDashboardPrefix = d['disableDashboardPrefix'] == true;
      _payloadIsJson = d['payloadIsJson'] == true;
      _showSentTimestamp = d['showSentTimestamp'] == true;
      _retain = d['retain'] == true;
      _pickerType = d['pickerType'] as String? ?? 'Date Time';
      _buttonSize = d['buttonSize'] as String? ?? 'Medium';
      _qos = int.tryParse(d['qos']?.toString() ?? '0') ?? 0;
      final colorVal = int.tryParse(d['buttonColor']?.toString() ?? '');
      if (colorVal != null) _buttonColor = Color(colorVal);
      final iconStr = d['icon'] as String?;
      if (iconStr != null) _panelIcon = iconFromString(iconStr) ?? Icons.widgets_outlined;
      _subscribeTopicCtrl.text = d['subscribeTopic'] as String? ?? '';
      _jsonPathCtrl.text    = d['jsonPath'] as String? ?? '';
      _jsonPatternCtrl.text = d['jsonPattern'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    _topicCtrl.dispose();
    _subscribeTopicCtrl.dispose();
    _jsonPathCtrl.dispose();
    _jsonPatternCtrl.dispose();
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
        title: const Text('Pick Button Color'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() => _buttonColor = c);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _buttonColor == c
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
        'type': 'Date & Time Picker',
        'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(),
        'icon': iconToString(_panelIcon),
        'pickerType': _pickerType,
        'buttonColor': _buttonColor.value.toString(),
        'buttonSize': _buttonSize,
        'retain': _retain,
        'qos': _qos,
        'disableDashboardPrefix': _disableDashboardPrefix,
        'payloadIsJson': _payloadIsJson,
        'showSentTimestamp': _showSentTimestamp,
        'subscribeTopic': _subscribeTopicCtrl.text.trim(),
        'jsonPath':    _jsonPathCtrl.text.trim(),
        'jsonPattern': _jsonPatternCtrl.text.trim(),
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
    String? Function(String?)? val,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: label,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
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
                style: const TextStyle(fontSize: 15, color: Colors.black87),
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context.watch<AppSettings>().languageCode);

    // Map internal values to translated labels
    final Map<String, String> typeLabels = {
      'Date Time': l.dateAndTime,
      'Date': l.date,
      'Time': l.time,
    };

    final Map<String, String> sizeLabels = {
      'Small': l.small,
      'Medium': l.medium,
      'Large': l.large,
    };

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
          _isEditing ? l.edit : l.addDateTimePickerPanel,
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
              help: true,
            ),
            _field(
              l.topic,
              _topicCtrl,
              req: true,
              val: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _field(l.subscribeTopic, _subscribeTopicCtrl),

            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            // Picker type
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.pickerType,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _pickerType,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(top: 4, bottom: 8),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                        ),
                        items: typeLabels.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _pickerType = v!),
                      ),
                    ],
                  ),
                ),
                _d(),
              ],
            ),

            // Button color (Re-using l.buttonColor from earlier screens)
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
                        l.buttonColor,
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
                            color: _buttonColor,
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
                _d(),
              ],
            ),

            // Button size
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.buttonSize,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _buttonSize,
                        underline: const SizedBox(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
                        items: sizeLabels.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _buttonSize = v!),
                      ),
                    ],
                  ),
                ),
                _d(),
              ],
            ),

            _check(
              l.payloadIsJson,
              _payloadIsJson,
              (v) => setState(() => _payloadIsJson = v),
            ),
            if (_payloadIsJson) ...[
              _field(l.jsonPath, _jsonPathCtrl),
              _field(l.jsonPattern, _jsonPatternCtrl),
            ],
            _check(
              l.showSentTimestamp,
              _showSentTimestamp,
              (v) => setState(() => _showSentTimestamp = v),
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
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Checkbox(
                          value: _retain,
                          onChanged: (v) =>
                              setState(() => _retain = v ?? false),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          side: const BorderSide(
                            color: Colors.black54,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l.retain,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'QoS',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _qos,
                        underline: Container(height: 1, color: Colors.black26),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
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

            // Action Buttons
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
                      child: Text(
                        l.cancel,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
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
