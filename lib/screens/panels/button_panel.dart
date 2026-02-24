import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../app_settings.dart';

class AddButtonPanelScreen extends StatefulWidget {
  const AddButtonPanelScreen({super.key});

  @override
  State<AddButtonPanelScreen> createState() => _AddButtonPanelScreenState();
}

class _AddButtonPanelScreenState extends State<AddButtonPanelScreen> {
  final _panelNameController       = TextEditingController();
  final _topicController           = TextEditingController();
  final _payloadController         = TextEditingController();
  final _separatePayloadController = TextEditingController();
  final _formKey                   = GlobalKey<FormState>();

  bool _disableDashboardPrefix = false;
  bool _noPayload              = false;
  bool _repeatPublish          = false;
  bool _fitToPanelWidth        = false;
  bool _useIconsForButton      = false;
  bool _payloadIsJson          = false;
  bool _showSentTimestamp      = false;
  bool _confirmBeforePublish   = false;
  bool _retain                 = false;

  Color  _buttonColor = const Color(0xFF1E88E5);
  String _buttonSize  = 'Medium';
  int    _qos         = 0;

  final List<String> _buttonSizes = ['Small', 'Medium', 'Large'];
  final List<int>    _qosOptions  = [0, 1, 2];

  @override
  void dispose() {
    _panelNameController.dispose();
    _topicController.dispose();
    _payloadController.dispose();
    _separatePayloadController.dispose();
    super.dispose();
  }

  void _pickColor() {
    final colors = [
      const Color(0xFF1E88E5), Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Button Color'),
        content: Wrap(
          spacing: 10, runSpacing: 10,
          children: colors.map((c) => GestureDetector(
            onTap: () { setState(() => _buttonColor = c); Navigator.pop(context); },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c, shape: BoxShape.circle,
                border: Border.all(
                  color: _buttonColor == c ? Colors.black : Colors.transparent,
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
        'type':            'Button',
        'label':           _panelNameController.text.trim(),
        'topic':           _topicController.text.trim(),
        'payload':         _noPayload ? '' : _payloadController.text.trim(),
        'separatePayload': _separatePayloadController.text.trim(),
        'buttonColor':     _buttonColor.value.toString(),
        'buttonSize':      _buttonSize,
        'noPayload':       _noPayload,
        'retain':          _retain,
        'qos':             _qos,
      });
    }
  }

  // ── Reusable widgets ─────────────────────────────────────────

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

  // Label above underline input — exactly as in the screenshot
  Widget _fieldRow(
      String label,
      TextEditingController ctrl, {
        bool required = false,
        bool showHelp = false,
        String? Function(String?)? validator,
        bool readOnly = false,
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
                          )
                        ]
                            : [],
                      ),
                    ),
                    TextFormField(
                      controller: ctrl,
                      validator: validator,
                      readOnly: readOnly,
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

  // Checkbox row — matches screenshot style
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
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

  Widget _helpIcon() => Container(
    width: 28,
    height: 28,
    decoration: const BoxDecoration(
      color: Color(0xFF1E88E5),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.question_mark, color: Colors.white, size: 15),
  );

  // ── Build ────────────────────────────────────────────────────

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
        title: const Text(
          'Add a Button panel',
          style: TextStyle(
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

            // Panel name
            _fieldRow(
              'Panel name', _panelNameController,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Panel name is required' : null,
            ),

            // Disable dashboard prefix topic
            _checkRow(
              'Disable dashboard prefix topic',
              _disableDashboardPrefix,
                  (v) => setState(() => _disableDashboardPrefix = v),
              showHelp: true,
            ),

            // Topic
            _fieldRow(
              'Topic', _topicController,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Topic is required' : null,
            ),

            // No payload
            _checkRow(
              'No payload', _noPayload,
                  (v) => setState(() => _noPayload = v),
              showHelp: true,
            ),

            // Payload — hidden when No payload checked
            if (!_noPayload)
              _fieldRow(
                'Payload', _payloadController,
                required: true,
                validator: (v) => (!_noPayload && (v == null || v.isEmpty))
                    ? 'Payload is required'
                    : null,
              ),

            // Separate payload on release
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
                            const Text(
                              'Separate payload on release',
                              style: TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                            TextField(
                              controller: _separatePayloadController,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 8),
                        child: _helpIcon(),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ],
            ),

            // Button color
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Button color',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
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
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ],
            ),

            // Button size
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Button size',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      DropdownButton<String>(
                        value: _buttonSize,
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                        items: _buttonSizes
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _buttonSize = v!),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ],
            ),

            // Checkboxes
            _checkRow('Repeat publish until released', _repeatPublish,
                    (v) => setState(() => _repeatPublish = v)),
            _checkRow('Fit to panel width', _fitToPanelWidth,
                    (v) => setState(() => _fitToPanelWidth = v)),
            _checkRow('Use icons for button', _useIconsForButton,
                    (v) => setState(() => _useIconsForButton = v)),
            _checkRow('Payload is JSON Data', _payloadIsJson,
                    (v) => setState(() => _payloadIsJson = v)),
            _checkRow('Show sent timestamp', _showSentTimestamp,
                    (v) => setState(() => _showSentTimestamp = v)),
            _checkRow('Confirm before publish', _confirmBeforePublish,
                    (v) => setState(() => _confirmBeforePublish = v)),

            // Retain + QoS on same row
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28, height: 28,
                        child: Checkbox(
                          value: _retain,
                          onChanged: (v) => setState(() => _retain = v ?? false),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: const BorderSide(color: Colors.black54, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Retain',
                          style: TextStyle(fontSize: 15, color: Colors.black87)),
                      const Spacer(),
                      const Text('QoS',
                          style: TextStyle(fontSize: 15, color: Colors.black87)),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _qos,
                        underline: Container(height: 1, color: Colors.black26),
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                        items: _qosOptions
                            .map((q) => DropdownMenuItem(value: q, child: Text('$q')))
                            .toList(),
                        onChanged: (v) => setState(() => _qos = v!),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ],
            ),

            // CANCEL / CREATE
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130, height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
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
                    width: 130, height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        elevation: 2,
                      ),
                      onPressed: _create,
                      child: const Text(
                        'CREATE',
                        style: TextStyle(
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