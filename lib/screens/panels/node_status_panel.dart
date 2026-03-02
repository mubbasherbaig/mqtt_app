import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddNodeStatusPanelScreen extends StatefulWidget {
  const AddNodeStatusPanelScreen({super.key, this.initialData});
  final Map<String, dynamic>? initialData;
  @override
  State<AddNodeStatusPanelScreen> createState() =>
      _AddNodeStatusPanelScreenState();
}

class _AddNodeStatusPanelScreenState extends State<AddNodeStatusPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();
  final _subscribeTopicCtrl = TextEditingController();
  final _payloadSyncRequestCtrl = TextEditingController();
  final _payloadOnlineCtrl = TextEditingController();
  final _payloadOfflineCtrl = TextEditingController();
  bool get _isEditing => widget.initialData != null;

  IconData _panelIcon = Icons.widgets_outlined;

  bool _disableDashboardPrefix = true;
  bool _autoSyncOnLoad = false;
  bool _enableNotification = false;
  bool _payloadIsJson = false;
  bool _showReceivedTimestamp = false;
  bool _showSentTimestamp = false;
  bool _retain = false;

  Color _onlineIconColor = const Color(0xFFFF5622);
  Color _offlineIconColor = const Color(0xFF9E9E9E);
  int _qos = 0;
  final List<int> _qosOptions = [0, 1, 2];
  final _jsonPathCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _panelNameCtrl.text = d['label'] as String? ?? d['panelName'] as String? ?? '';
      _topicCtrl.text = d['topic'] as String? ?? '';
      _subscribeTopicCtrl.text = d['subscribeTopic'] as String? ?? '';
      _payloadSyncRequestCtrl.text = d['payloadSyncRequest'] as String? ?? '';
      _payloadOnlineCtrl.text = d['payloadOnline'] as String? ?? '';
      _payloadOfflineCtrl.text = d['payloadOffline'] as String? ?? '';
      _disableDashboardPrefix = d['disableDashboardPrefix'] == true;
      _autoSyncOnLoad = d['autoSyncOnLoad'] == true;
      _payloadIsJson = d['payloadIsJson'] == true;
      _showReceivedTimestamp = d['showReceivedTimestamp'] == true;
      _showSentTimestamp = d['showSentTimestamp'] == true;
      _retain = d['retain'] == true;
      _qos = int.tryParse(d['qos']?.toString() ?? '0') ?? 0;
      final onlineColorVal = int.tryParse(d['onlineIconColor']?.toString() ?? '');
      if (onlineColorVal != null) _onlineIconColor = Color(onlineColorVal);
      final offlineColorVal = int.tryParse(d['offlineIconColor']?.toString() ?? '');
      if (offlineColorVal != null) _offlineIconColor = Color(offlineColorVal);
      final iconStr = d['icon'] as String?;
      if (iconStr != null) _panelIcon = iconFromString(iconStr) ?? Icons.widgets_outlined;
      _jsonPathCtrl.text    = d['jsonPath'] as String? ?? '';
      _enableNotification = d['enableNotification'] == true;
    }
  }

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    _topicCtrl.dispose();
    _subscribeTopicCtrl.dispose();
    _payloadSyncRequestCtrl.dispose();
    _payloadOnlineCtrl.dispose();
    _payloadOfflineCtrl.dispose();
    _jsonPathCtrl.dispose();
    super.dispose();
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Node Status',
        'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(),
        'subscribeTopic': _subscribeTopicCtrl.text.trim(),
        'payloadSyncRequest': _payloadSyncRequestCtrl.text.trim(),
        'payloadOnline': _payloadOnlineCtrl.text.trim(),
        'payloadOffline': _payloadOfflineCtrl.text.trim(),
        'icon': iconToString(_panelIcon),
        'onlineIconColor': _onlineIconColor.value.toString(),
        'offlineIconColor': _offlineIconColor.value.toString(),
        'disableDashboardPrefix': _disableDashboardPrefix,
        'autoSyncOnLoad': _autoSyncOnLoad,
        'payloadIsJson': _payloadIsJson,
        'showReceivedTimestamp': _showReceivedTimestamp,
        'showSentTimestamp': _showSentTimestamp,
        'retain': _retain,
        'qos': _qos,
        'jsonPath':    _jsonPathCtrl.text.trim(),
        'enableNotification': _enableNotification,
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
                        focusedErrorBorder: UnderlineInputBorder(
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

  // Icon row with color dot and hex code
  Widget _iconRow(
    String iconLabel,
    bool isOnline,
    Color color,
    VoidCallback onColorTap,
    AppLocalizations l,
  ) {
    final hexColor =
        '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isOnline ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                color: isOnline ? Colors.orange : Colors.grey,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(iconLabel, style: const TextStyle(fontSize: 15)),
              ),
              GestureDetector(
                onTap: onColorTap,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.iconColor,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    hexColor,
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

  void _pickIconColor(bool isOnline, AppLocalizations l) {
    final colors = [
      const Color(0xFFFF5622),
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
        title: Text(isOnline ? 'Online Icon Color' : 'Offline Icon Color'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isOnline)
                        _onlineIconColor = c;
                      else
                        _offlineIconColor = c;
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
                        color:
                            (isOnline ? _onlineIconColor : _offlineIconColor) ==
                                c
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
          _isEditing ? l.edit : l.addNodeStatusPanel,
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
              _topicCtrl,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _fieldRow(l.subscribeTopic, _subscribeTopicCtrl, showHelp: true),
            _fieldRow(
              l.payloadSyncRequest,
              _payloadSyncRequestCtrl,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _fieldRow(
              l.payloadOnline,
              _payloadOnlineCtrl,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            _fieldRow(
              l.payloadOffline,
              _payloadOfflineCtrl,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            _divider(),
            // Icon rows
            _iconRow(
              l.onlineIcon,
              true,
              _onlineIconColor,
              () => _pickIconColor(true, l),
              l,
            ),
            _iconRow(
              l.offlineIcon,
              false,
              _offlineIconColor,
              () => _pickIconColor(false, l),
              l,
            ),

            _checkRow(
              l.autoSyncOnLoad,
              _autoSyncOnLoad,
              (v) => setState(() => _autoSyncOnLoad = v),
            ),
            _checkRow(
              l.enableNotification,
              _enableNotification,
                  (v) => setState(() => _enableNotification = v),
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
            _checkRow(
              l.showSentTimestamp,
              _showSentTimestamp,
              (v) => setState(() => _showSentTimestamp = v),
            ),

            // QoS and Retain Section
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
                      Text(l.retain, style: const TextStyle(fontSize: 15)),
                      const Spacer(),
                      const Text('QoS', style: TextStyle(fontSize: 15)),
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
