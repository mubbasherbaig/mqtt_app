import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddSwitchPanelScreen extends StatefulWidget {
  const AddSwitchPanelScreen({super.key, this.initialData});

  final Map<String, dynamic>? initialData;
  @override
  State<AddSwitchPanelScreen> createState() => _AddSwitchPanelScreenState();
}

class _AddSwitchPanelScreenState extends State<AddSwitchPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameController = TextEditingController();
  final _topicController = TextEditingController();
  final _subscribeTopicController = TextEditingController();
  final _payloadOnController = TextEditingController(text: '1');
  final _payloadOffController = TextEditingController(text: '0');

  bool get _isEditing => widget.initialData != null;

  IconData _panelIcon = Icons.widgets_outlined;

  bool _disableDashboardPrefix = false;
  bool _payloadIsJson = false;
  bool _showReceivedTimestamp = false;
  bool _showSentTimestamp = false;
  bool _retain = false;
  Color _switchColor = const Color(0xFF1E88E5);
  int _qos = 0;
  final List<int> _qosOptions = [0, 1, 2];

  bool _useIconSwitch = false;
  IconData _onIcon = Icons.lightbulb;
  IconData _offIcon = Icons.lightbulb_outline;
  Color _onIconColor = const Color(0xFFC00000);
  Color _offIconColor = const Color(0xFF005C00);
  String _iconSize = 'Small';
  final List<String> _iconSizes = ['Small', 'Medium', 'Large'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _panelNameController.text = d['label'] as String? ?? d['panelName'] as String? ?? '';
      _topicController.text = d['topic'] as String? ?? '';
      _subscribeTopicController.text = d['subscribeTopic'] as String? ?? '';
      _payloadOnController.text = d['payloadOn'] as String? ?? '1';
      _payloadOffController.text = d['payloadOff'] as String? ?? '0';
      _disableDashboardPrefix = d['disableDashboardPrefix'] == true;
      _payloadIsJson = d['payloadIsJson'] == true;
      _showReceivedTimestamp = d['showReceivedTimestamp'] == true;
      _showSentTimestamp = d['showSentTimestamp'] == true;
      _retain = d['retain'] == true;
      _useIconSwitch = d['useIconSwitch'] == true;
      _iconSize = d['iconSize'] as String? ?? 'Small';
      _qos = int.tryParse(d['qos']?.toString() ?? '0') ?? 0;
      final colorVal = int.tryParse(d['switchColor']?.toString() ?? '');
      if (colorVal != null) _switchColor = Color(colorVal);
      final onColorVal = int.tryParse(d['onIconColor']?.toString() ?? '');
      if (onColorVal != null) _onIconColor = Color(onColorVal);
      final offColorVal = int.tryParse(d['offIconColor']?.toString() ?? '');
      if (offColorVal != null) _offIconColor = Color(offColorVal);
      final iconStr = d['icon'] as String?;
      if (iconStr != null) _panelIcon = iconFromString(iconStr) ?? Icons.widgets_outlined;
      final onIconStr = d['onIcon'] as String?;
      if (onIconStr != null) _onIcon = iconFromString(onIconStr) ?? Icons.lightbulb;
      final offIconStr = d['offIcon'] as String?;
      if (offIconStr != null) _offIcon = iconFromString(offIconStr) ?? Icons.lightbulb_outline;
    }
  }

  @override
  void dispose() {
    _panelNameController.dispose();
    _topicController.dispose();
    _subscribeTopicController.dispose();
    _payloadOnController.dispose();
    _payloadOffController.dispose();
    super.dispose();
  }

  void _pickColor() {
    final colors = [
      const Color(0xFF1E88E5),
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Switch Color'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() => _switchColor = c);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _switchColor == c
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

  void _pickIconColor(bool isOn, AppLocalizations l) {
    final colors = [
      const Color(0xFFC00000), const Color(0xFF005C00),
      const Color(0xFF1E88E5), Colors.orange, Colors.purple,
      Colors.teal, Colors.pink, const Color(0xFF9E9E9E),
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isOn ? l.onIcon : l.offIcon),
        content: Wrap(
          spacing: 10, runSpacing: 10,
          children: colors.map((c) => GestureDetector(
            onTap: () {
              setState(() => isOn ? _onIconColor = c : _offIconColor = c);
              Navigator.pop(context);
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c, shape: BoxShape.circle,
                border: Border.all(
                  color: (isOn ? _onIconColor : _offIconColor) == c ? Colors.black : Colors.transparent,
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
        'type': 'Switch',
        'label': _panelNameController.text.trim(),
        'topic': _topicController.text.trim(),
        'subscribeTopic': _subscribeTopicController.text.trim(),
        'payloadOn': _payloadOnController.text.trim(),
        'payloadOff': _payloadOffController.text.trim(),
        'icon': iconToString(_panelIcon),
        'switchColor': _switchColor.value.toString(),
        'retain': _retain,
        'qos': _qos,
        'disableDashboardPrefix': _disableDashboardPrefix,
        'payloadIsJson': _payloadIsJson,
        'showReceivedTimestamp': _showReceivedTimestamp,
        'showSentTimestamp': _showSentTimestamp,
        'useIconSwitch': _useIconSwitch,
        'onIcon': iconToString(_onIcon),
        'offIcon': iconToString(_offIcon),
        'onIconColor': _onIconColor.value.toString(),
        'offIconColor': _offIconColor.value.toString(),
        'iconSize': _iconSize,
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
    Widget? trailingIcon,
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
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 8),
                  child: trailingIcon,
                ),
              if (showHelp && trailingIcon == null)
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
          _isEditing ? l.edit : l.addSwitchPanel,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
              _panelNameController,
              required: true,
              trailingIcon: const Icon(
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
              _topicController,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _fieldRow(
              l.subscribeTopic,
              _subscribeTopicController,
              showHelp: true,
            ),
            _fieldRow(
              l.payloadOn,
              _payloadOnController,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _fieldRow(
              l.payloadOff,
              _payloadOffController,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            _divider(),
            // Switch color
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
                        l.sliderColor,
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
                            color: _switchColor,
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
            // Use Icon Switch checkbox
            _checkRow(
              l.useIconSwitch,
              _useIconSwitch,
                  (v) => setState(() => _useIconSwitch = v),
            ),

            if (_useIconSwitch) ...[
              // On Icon row
              Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Icon(Icons.sensors, color: _onIconColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.onIcon, style: const TextStyle(fontSize: 15, color: Colors.black87))),
                    GestureDetector(
                      onTap: () => _pickIconColor(true, l),
                      child: Container(width: 34, height: 34, decoration: BoxDecoration(color: _onIconColor, shape: BoxShape.circle)),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.iconColor, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      Text('#${_onIconColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ]),
                  ]),
                ),
                _divider(),
              ]),
              // Off Icon row
              Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Icon(Icons.sensors, color: _offIconColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.offIcon, style: const TextStyle(fontSize: 15, color: Colors.black87))),
                    GestureDetector(
                      onTap: () => _pickIconColor(false, l),
                      child: Container(width: 34, height: 34, decoration: BoxDecoration(color: _offIconColor, shape: BoxShape.circle)),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.iconColor, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      Text('#${_offIconColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ]),
                  ]),
                ),
                _divider(),
              ]),
              // Icon size
              Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.iconSize, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      DropdownButton<String>(
                        value: _iconSize,
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                        items: _iconSizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _iconSize = v!),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ]),
            ],
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
            _checkRow(
              l.showSentTimestamp,
              _showSentTimestamp,
              (v) => setState(() => _showSentTimestamp = v),
            ),
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
                      Text(
                        l.qos,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
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
                _divider(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l.cancel,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.8,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _create,
                      child: Text(
                        _isEditing ? l.save : l.create,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.8,
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
