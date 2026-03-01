import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddMultiStateIndicatorPanelScreen extends StatefulWidget {
  const AddMultiStateIndicatorPanelScreen({super.key, this.initialData});
  final Map<String, dynamic>? initialData;
  @override
  State<AddMultiStateIndicatorPanelScreen> createState() =>
      _AddMultiStateIndicatorPanelScreenState();
}

class _AddMultiStateIndicatorPanelScreenState
    extends State<AddMultiStateIndicatorPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();

  IconData _panelIcon = Icons.widgets_outlined;
  bool get _isEditing => widget.initialData != null;

  bool _disableDashboardPrefix = true;
  bool _enableNotification = false;
  bool _payloadIsJson = false;
  bool _showReceivedTimestamp = false;
  bool _showSentTimestamp = false;
  bool _retain = false;

  String _iconSize = 'Small';
  int _qos = 0;

  final List<String> _iconSizes = ['Small', 'Medium', 'Large'];
  final List<int> _qosOptions = [0, 1, 2];

  // Each item: label, payload, iconColor
  final List<Map<String, dynamic>> _items = [];

  final _jsonPathCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _panelNameCtrl.text = d['label'] as String? ?? d['panelName'] as String? ?? '';
      _topicCtrl.text = d['topic'] as String? ?? '';
      _disableDashboardPrefix = d['disableDashboardPrefix'] == true;
      _payloadIsJson = d['payloadIsJson'] == true;
      _showReceivedTimestamp = d['showReceivedTimestamp'] == true;
      _showSentTimestamp = d['showSentTimestamp'] == true;
      _retain = d['retain'] == true;
      _iconSize = d['iconSize'] as String? ?? 'Small';
      _qos = int.tryParse(d['qos']?.toString() ?? '0') ?? 0;
      final iconStr = d['icon'] as String?;
      if (iconStr != null) _panelIcon = iconFromString(iconStr) ?? Icons.widgets_outlined;
      _jsonPathCtrl.text    = d['jsonPath'] as String? ?? '';
      final savedItems = d['items'];
      if (savedItems is List && savedItems.isNotEmpty) {
        for (final item in savedItems) {
          final colorVal = int.tryParse(item['color']?.toString() ?? '');
          _items.add({
            'label': TextEditingController(text: item['label']?.toString() ?? ''),
            'payload': TextEditingController(text: item['payload']?.toString() ?? ''),
            'color': colorVal != null ? Color(colorVal) : const Color(0xFF9E9E9E),
          });
        }
      } else {
        _addItem();
        _addItem();
      }
    } else {
      _addItem();
      _addItem();
    }
  }

  void _addItem() => _items.add({
    'label': TextEditingController(),
    'payload': TextEditingController(),
    'color': const Color(0xFF9E9E9E),
  });

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    _topicCtrl.dispose();
    for (final i in _items) {
      (i['label'] as TextEditingController).dispose();
      (i['payload'] as TextEditingController).dispose();
    }
    _jsonPathCtrl.dispose();
    super.dispose();
  }

  void _pickItemColor(int index, AppLocalizations l) {
    // Added 'l'
    final colors = [
      Colors.red,
      Colors.green,
      const Color(0xFF1E88E5),
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      const Color(0xFF9E9E9E),
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.pickIconColor), // Use localized title
        content: Wrap(/* ... rest of your code ... */),
      ),
    );
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Multi-State Indicator',
        'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(),
        'icon': iconToString(_panelIcon),
        'iconSize': _iconSize,
        'items': _items
            .map(
              (i) => {
                'label': (i['label'] as TextEditingController).text.trim(),
                'payload': (i['payload'] as TextEditingController).text.trim(),
                'color': (i['color'] as Color).value.toString(),
              },
            )
            .toList(),
        // ADD THESE MISSING FIELDS:
        'disableDashboardPrefix': _disableDashboardPrefix,
        'payloadIsJson': _payloadIsJson,
        'showReceivedTimestamp': _showReceivedTimestamp,
        'showSentTimestamp': _showSentTimestamp,
        'retain': _retain,
        'qos': _qos,
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
    Widget? trailing,
    String? Function(String?)? validator,
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
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 8),
                  child: trailing,
                ),
            ],
          ),
        ),
        _divider(),
      ],
    );
  }

  Widget _itemIconRow(int index, AppLocalizations l) {
    final color = _items[index]['color'] as Color;
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ... (radio icon)
              const SizedBox(width: 10),
              Text(
                l.chooseIcon,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              // Use localized text
              const Spacer(),
              GestureDetector(
                onTap: () => _pickItemColor(index, l), // Pass 'l' here
                child: Container(
                  width: 34,
                  height: 34,
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
                    const Text(
                      'Icon color',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black26),
                        ),
                      ),
                      child: Text(
                        hex,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
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
          _isEditing ? l.edit : l.addMultiStateIndicator,
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
              trailing: const Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.black45,
                size: 22,
              ),
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
            // Dynamic State Items
            ...List.generate(
              _items.length,
              (i) => Column(
                children: [
                  _fieldRow(
                    '${l.labelForItem} ${i + 1}',
                    _items[i]['label'] as TextEditingController,
                  ),
                  _fieldRow(
                    '${l.payloadForItem} ${i + 1}',
                    _items[i]['payload'] as TextEditingController,
                    required: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l.required : null,
                  ),
                  _itemIconRow(i, l), // Passed localizations helper
                ],
              ),
            ),

            // Add More Button
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
                        l.addMoreItem,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _addItem()),
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
                _divider(),
              ],
            ),

            // Icon Size
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
                        l.iconSize,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _iconSize,
                        underline: const SizedBox(),
                        items: sizeLabels.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _iconSize = v!),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ],
            ),

            _checkRow(
              l.payloadIsJson,
              _payloadIsJson,
              (v) => setState(() => _payloadIsJson = v),
            ),
            if (_payloadIsJson) ...[
              _fieldRow(l.jsonPath, _jsonPathCtrl),
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
