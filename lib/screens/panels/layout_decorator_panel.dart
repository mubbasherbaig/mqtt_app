import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

class AddLayoutDecoratorPanelScreen extends StatefulWidget {
  const AddLayoutDecoratorPanelScreen({super.key});

  @override
  State<AddLayoutDecoratorPanelScreen> createState() =>
      _AddLayoutDecoratorPanelScreenState();
}

class _AddLayoutDecoratorPanelScreenState
    extends State<AddLayoutDecoratorPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panelNameCtrl = TextEditingController();
  IconData _panelIcon = Icons.widgets_outlined;
  String _titleAlignment = 'Center';
  String _textSize = '20px';

  final List<String> _alignments = ['Left', 'Center', 'Right'];
  final List<String> _textSizes = [
    '12px',
    '14px',
    '16px',
    '18px',
    '20px',
    '24px',
    '28px',
    '32px',
  ];

  @override
  void dispose() {
    _panelNameCtrl.dispose();
    super.dispose();
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'type': 'Layout Decorator',
        'label': _panelNameCtrl.text.trim(),
        'titleAlignment': _titleAlignment,
        'icon': iconToString(_panelIcon),
        'textSize': _textSize,
      });
    }
  }

  Widget _d() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context.watch<AppSettings>().languageCode);

    final Map<String, String> alignmentLabels = {
      'Left': l.left,
      'Center': l.center,
      'Right': l.right,
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
          l.addLayoutDecoratorPanel,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                l.layoutDecoratorInfo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            // Panel name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: l.panelName,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          children: const [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _panelNameCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? l.required : null,
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
                        ),
                      ),
                    ],
                  ),
                ),
                _d(),
              ],
            ),
            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            // Alignment and Text Size Row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.titleAlignment,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _titleAlignment,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: 4,
                                  bottom: 8,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26),
                                ),
                              ),
                              items: alignmentLabels.entries
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _titleAlignment = v!),
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
                              l.textSize,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _textSize,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: 4,
                                  bottom: 8,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26),
                                ),
                              ),
                              items: _textSizes
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _textSize = v!),
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
