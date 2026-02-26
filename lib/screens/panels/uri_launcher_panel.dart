import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddUriLauncherPanelScreen extends StatefulWidget {
  const AddUriLauncherPanelScreen({super.key});

  @override
  State<AddUriLauncherPanelScreen> createState() =>
      _AddUriLauncherPanelScreenState();
}

class _AddUriLauncherPanelScreenState extends State<AddUriLauncherPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();

  IconData _panelIcon = Icons.widgets_outlined;

  bool _disableDashboardPrefix = false;
  bool _staticUrl = false;
  bool _enableNotification = false;
  bool _payloadIsJson = false;
  bool _showReceivedTimestamp = false;
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
        'type': 'URI Launcher',
        'label': _panelNameCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(),
        'staticUrl': _staticUrl,
        'qos': _qos,
        'icon': iconToString(_panelIcon),
        'disableDashboardPrefix': _disableDashboardPrefix,
        'payloadIsJson': _payloadIsJson,
        'showReceivedTimestamp': _showReceivedTimestamp,
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
          l.addUriLauncherPanel,
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
            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            _check(
              l.staticUrl,
              _staticUrl,
              (v) => setState(() => _staticUrl = v),
            ),
            _check(
              l.payloadIsJson,
              _payloadIsJson,
              (v) => setState(() => _payloadIsJson = v),
            ),
            _check(
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
