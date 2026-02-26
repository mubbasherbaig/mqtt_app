import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddTextInputPanelScreen extends StatefulWidget {
  const AddTextInputPanelScreen({super.key});

  @override
  State<AddTextInputPanelScreen> createState() =>
      _AddTextInputPanelScreenState();
}

class _AddTextInputPanelScreenState extends State<AddTextInputPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();

  IconData _panelIcon = Icons.widgets_outlined;

  bool _disableDashboardPrefix = false;
  bool _clearTextOnPublish = false;
  bool _payloadIsJson = false;
  bool _showSentTimestamp = false;
  bool _confirmBeforePublish = false;
  bool _retain = false;
  int _qos = 0;
  final List<int> _qosOptions = [0, 1, 2];

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    _topicCtrl.dispose();
    super.dispose();
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Text Input',
        'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(),
        'icon': iconToString(_panelIcon),
        'disableDashboardPrefix': _disableDashboardPrefix,
        'clearTextOnPublish': _clearTextOnPublish,
        'payloadIsJson': _payloadIsJson,
        'showSentTimestamp': _showSentTimestamp,
        'confirmBeforePublish': _confirmBeforePublish,
        'retain': _retain,
        'qos': _qos,
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

  Widget _checkRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool showHelp = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    value: value,
                    onChanged: (v) => onChanged(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(color: Colors.black54, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
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
          l.addTextInputPanel,
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
            _checkRow(
              l.clearTextOnPublish,
              _clearTextOnPublish,
              (v) => setState(() => _clearTextOnPublish = v),
            ),
            _checkRow(
              l.payloadIsJson,
              _payloadIsJson,
              (v) => setState(() => _payloadIsJson = v),
            ),
            _checkRow(
              l.showSentTimestamp,
              _showSentTimestamp,
              (v) => setState(() => _showSentTimestamp = v),
            ),
            _checkRow(
              l.confirmBeforePublish,
              _confirmBeforePublish,
              (v) => setState(() => _confirmBeforePublish = v),
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
                        l.create,
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
