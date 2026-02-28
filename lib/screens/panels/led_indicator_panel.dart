import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddLedIndicatorPanelScreen extends StatefulWidget {
  const AddLedIndicatorPanelScreen({super.key, this.initialData});
  final Map<String, dynamic>? initialData;
  @override
  State<AddLedIndicatorPanelScreen> createState() =>
      _AddLedIndicatorPanelScreenState();
}

class _AddLedIndicatorPanelScreenState
    extends State<AddLedIndicatorPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();
  final _payloadOnCtrl = TextEditingController();
  final _payloadOffCtrl = TextEditingController();
  bool get _isEditing => widget.initialData != null;

  IconData _panelIcon = Icons.widgets_outlined;

  bool _disableDashboardPrefix = false;
  bool _payloadIsJson = false;
  bool _showReceivedTimestamp = false;

  Color _onIconColor = const Color(0xFFDF0000);
  Color _offIconColor = const Color(0xFF9E9E9E);
  String _iconSize = 'Small';
  int _qos = 0;

  final List<String> _iconSizes = ['Small', 'Medium', 'Large'];
  final List<int> _qosOptions = [0, 1, 2];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _panelNameCtrl.text = d['label'] as String? ?? d['panelName'] as String? ?? '';
      _topicCtrl.text = d['topic'] as String? ?? '';
      _payloadOnCtrl.text = d['payloadOn'] as String? ?? '';
      _payloadOffCtrl.text = d['payloadOff'] as String? ?? '';
      _disableDashboardPrefix = d['disableDashboardPrefix'] == true;
      _payloadIsJson = d['payloadIsJson'] == true;
      _showReceivedTimestamp = d['showReceivedTimestamp'] == true;
      _iconSize = d['iconSize'] as String? ?? 'Small';
      _qos = int.tryParse(d['qos']?.toString() ?? '0') ?? 0;
      final onColorVal = int.tryParse(d['onIconColor']?.toString() ?? '');
      if (onColorVal != null) _onIconColor = Color(onColorVal);
      final offColorVal = int.tryParse(d['offIconColor']?.toString() ?? '');
      if (offColorVal != null) _offIconColor = Color(offColorVal);
      final iconStr = d['icon'] as String?;
      if (iconStr != null) _panelIcon = iconFromString(iconStr) ?? Icons.widgets_outlined;
    }
  }

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    _topicCtrl.dispose();
    _payloadOnCtrl.dispose();
    _payloadOffCtrl.dispose();
    super.dispose();
  }

  void _pickColor(bool isOn, AppLocalizations l) {
    final colors = [
      const Color(0xFFDF0000),
      Colors.red,
      Colors.green,
      const Color(0xFF1E88E5),
      Colors.orange,
      Colors.purple,
      Colors.teal,
      const Color(0xFF9E9E9E),
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isOn ? l.onIcon : l.offIcon), // Localized Title
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isOn)
                        _onIconColor = c;
                      else
                        _offIconColor = c;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (isOn ? _onIconColor : _offIconColor) == c
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
        'type': 'LED Indicator',
        'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(),
        'icon': iconToString(_panelIcon),
        'payloadOn': _payloadOnCtrl.text.trim(),
        'payloadOff': _payloadOffCtrl.text.trim(),
        'onIconColor': _onIconColor.value.toString(),
        'offIconColor': _offIconColor.value.toString(),
        'iconSize': _iconSize,
        'qos': _qos,
        'disableDashboardPrefix': _disableDashboardPrefix,
        'payloadIsJson': _payloadIsJson,
        'showReceivedTimestamp': _showReceivedTimestamp,
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
          _isEditing ? l.edit : l.addLedIndicatorPanel,
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
            _fieldRow(
              l.payloadOn,
              _payloadOnCtrl,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _fieldRow(
              l.payloadOff,
              _payloadOffCtrl,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            _divider(),
            // Icon rows using localized labels
            _iconRow(l.onIcon, true, _onIconColor, l),
            _iconRow(l.offIcon, false, _offIconColor, l),

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
            _checkRow(
              l.showReceivedTimestamp,
              _showReceivedTimestamp,
              (v) => setState(() => _showReceivedTimestamp = v),
            ),

            // QoS Row
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      const Text(
                        'QoS',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _qos,
                        underline: Container(height: 1, color: Colors.black26),
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
                _divider(),
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

  // Modified helper to accept localization
  Widget _iconRow(String label, bool isOn, Color color, AppLocalizations l) {
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.sensors, color: isOn ? color : Colors.grey, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: () => _pickColor(isOn, l),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.iconColor,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    hex,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
        _divider(),
      ],
    );
  }
}
