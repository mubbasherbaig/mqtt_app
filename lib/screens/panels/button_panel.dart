import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../app_settings.dart';
import '../widgets/icon_picker_sheet.dart';
import '../widgets/panel_icon_picker_row.dart';

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
  IconData _panelIcon = Icons.widgets_outlined;
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

  void _pickColor(AppLocalizations l) {
    final colors = [
      const Color(0xFF1E88E5), Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.buttonColor),
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
        'icon': iconToString(_panelIcon),
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

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

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
                        style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
                        children: required ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
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
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E88E5))),
                        errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                        focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
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

  Widget _checkRow(String label, bool value, ValueChanged<bool> onChanged, {bool showHelp = false}) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 28, height: 28,
                  child: Checkbox(
                    value: value,
                    onChanged: (v) => onChanged(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(color: Colors.black54, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87))),
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
    width: 28, height: 28,
    decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
    child: const Icon(Icons.question_mark, color: Colors.white, size: 15),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context.watch<AppSettings>().languageCode);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.addButtonPanel,
          style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
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
            _fieldRow(l.panelName, _panelNameController, required: true, validator: (v) => (v == null || v.isEmpty) ? l.required : null),
            _checkRow(l.disableDashboardPrefix, _disableDashboardPrefix, (v) => setState(() => _disableDashboardPrefix = v), showHelp: true),
            _fieldRow(l.topic, _topicController, required: true, validator: (v) => (v == null || v.isEmpty) ? l.required : null),
            _checkRow(l.noPayload, _noPayload, (v) => setState(() => _noPayload = v), showHelp: true),

            if (!_noPayload)
              _fieldRow(l.payload, _payloadController, required: true, validator: (v) => (!_noPayload && (v == null || v.isEmpty)) ? l.required : null),

            // Separate payload on release
            _fieldRow(l.separatePayload, _separatePayloadController, showHelp: true),
            PanelIconPickerRow(
              selectedIcon: _panelIcon,
              onChanged: (icon) => setState(() => _panelIcon = icon),
            ),
            _divider(),
            // Button color picker
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.buttonColor, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      GestureDetector(
                        onTap: () => _pickColor(l),
                        child: Container(
                          width: 110, height: 36,
                          decoration: BoxDecoration(color: _buttonColor, borderRadius: BorderRadius.circular(4)),
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
                      Text(l.buttonSize, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      DropdownButton<String>(
                        value: _buttonSize,
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                        items: _buttonSizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _buttonSize = v!),
                      ),
                    ],
                  ),
                ),
                _divider(),
              ],
            ),

            _checkRow(l.repeatPublish, _repeatPublish, (v) => setState(() => _repeatPublish = v)),
            _checkRow(l.fitToWidth, _fitToPanelWidth, (v) => setState(() => _fitToPanelWidth = v)),
            _checkRow(l.useIcons, _useIconsForButton, (v) => setState(() => _useIconsForButton = v)),
            _checkRow(l.payloadIsJson, _payloadIsJson, (v) => setState(() => _payloadIsJson = v)),
            _checkRow(l.showSentTimestamp, _showSentTimestamp, (v) => setState(() => _showSentTimestamp = v)),
            _checkRow(l.confirmBeforePublish, _confirmBeforePublish, (v) => setState(() => _confirmBeforePublish = v)),

            // Retain + QoS row
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
                      Text(l.retain, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      const Spacer(),
                      Text(l.qos, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _qos,
                        underline: Container(height: 1, color: Colors.black26),
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                        items: _qosOptions.map((q) => DropdownMenuItem(value: q, child: Text('$q'))).toList(),
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
                    width: 130, height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.cancel, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.8)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 130, height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        elevation: 2,
                      ),
                      onPressed: _create,
                      child: Text(l.create, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.8)),
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