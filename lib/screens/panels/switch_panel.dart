import 'package:flutter/material.dart';

class AddSwitchPanelScreen extends StatefulWidget {
  const AddSwitchPanelScreen({super.key});

  @override
  State<AddSwitchPanelScreen> createState() => _AddSwitchPanelScreenState();
}

class _AddSwitchPanelScreenState extends State<AddSwitchPanelScreen> {
  final _panelNameController       = TextEditingController();
  final _topicController           = TextEditingController();
  final _subscribeTopicController  = TextEditingController();
  final _payloadOnController       = TextEditingController();
  final _payloadOffController      = TextEditingController();
  final _formKey                   = GlobalKey<FormState>();

  bool _disableDashboardPrefix    = false;
  bool _useIconSwitch             = false;
  bool _enableNotification        = false;
  bool _payloadIsJson             = false;
  bool _showReceivedTimestamp     = false;
  bool _showSentTimestamp         = false;
  bool _confirmBeforePublish      = false;
  bool _retain                    = false;

  Color  _switchColor = const Color(0xFF1E88E5);
  int    _qos         = 0;

  final List<int> _qosOptions = [0, 1, 2];

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
      const Color(0xFF1E88E5), Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Switch Color'),
        content: Wrap(
          spacing: 10, runSpacing: 10,
          children: colors.map((c) => GestureDetector(
            onTap: () { setState(() => _switchColor = c); Navigator.pop(context); },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c, shape: BoxShape.circle,
                border: Border.all(
                  color: _switchColor == c ? Colors.black : Colors.transparent,
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
        'type':             'Switch',
        'label':            _panelNameController.text.trim(),
        'topic':            _topicController.text.trim(),
        'subscribeTopic':   _subscribeTopicController.text.trim(),
        'payloadOn':        _payloadOnController.text.trim(),
        'payloadOff':       _payloadOffController.text.trim(),
        'switchColor':      _switchColor.value.toString(),
        'retain':           _retain,
        'qos':              _qos,
      });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

  Widget _helpIcon() => Container(
    width: 28, height: 28,
    decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
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
                        style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
                        children: required
                            ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                            : [],
                      ),
                    ),
                    TextFormField(
                      controller: ctrl,
                      validator: validator,
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
              if (trailingIcon != null)
                Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: trailingIcon),
              if (showHelp && trailingIcon == null)
                Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: _helpIcon()),
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
                  width: 28, height: 28,
                  child: Checkbox(
                    value: value,
                    onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(color: enabled ? Colors.black54 : Colors.black26, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
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

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
          'Add a Switch panel',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
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

            // Panel name — with eye icon on right like in image
            _fieldRow(
              'Panel name', _panelNameController,
              required: true,
              trailingIcon: const Icon(Icons.remove_red_eye_outlined, color: Colors.black45, size: 22),
              validator: (v) => (v == null || v.isEmpty) ? 'Panel name is required' : null,
            ),

            // Disable dashboard prefix topic
            _checkRow(
              'Disable dashboard prefix topic', _disableDashboardPrefix,
                  (v) => setState(() => _disableDashboardPrefix = v),
              showHelp: true,
            ),

            // Topic
            _fieldRow(
              'Topic', _topicController,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Topic is required' : null,
            ),

            // Subscribe Topic
            _fieldRow(
              'Subscribe Topic', _subscribeTopicController,
              showHelp: true,
            ),

            // Payload on
            _fieldRow(
              'Payload on', _payloadOnController,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Payload on is required' : null,
            ),

            // Payload off
            _fieldRow(
              'Payload off', _payloadOffController,
              required: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Payload off is required' : null,
            ),

            // Switch color
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Switch color', style: TextStyle(fontSize: 15, color: Colors.black87)),
                      GestureDetector(
                        onTap: _pickColor,
                        child: Container(
                          width: 110, height: 36,
                          decoration: BoxDecoration(
                            color: _switchColor,
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

            // Use icon switch
            _checkRow('Use icon switch', _useIconSwitch,
                    (v) => setState(() => _useIconSwitch = v)),

            // Enable notification or alarm (greyed out — depends on Use icon switch)
            _checkRow(
              'Enable notification or alarm', _enableNotification,
                  (v) => setState(() => _enableNotification = v),
              showHelp: true,
              enabled: _useIconSwitch,
            ),

            // Payload is JSON Data
            _checkRow('Payload is JSON Data', _payloadIsJson,
                    (v) => setState(() => _payloadIsJson = v)),

            // Show received timestamp
            _checkRow('Show received timestamp', _showReceivedTimestamp,
                    (v) => setState(() => _showReceivedTimestamp = v)),

            // Show sent timestamp
            _checkRow('Show sent timestamp', _showSentTimestamp,
                    (v) => setState(() => _showSentTimestamp = v)),

            // Confirm before publish
            _checkRow('Confirm before publish', _confirmBeforePublish,
                    (v) => setState(() => _confirmBeforePublish = v)),

            // Retain + QoS
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
                      const Text('Retain', style: TextStyle(fontSize: 15, color: Colors.black87)),
                      const Spacer(),
                      const Text('QoS', style: TextStyle(fontSize: 15, color: Colors.black87)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.8),
                      ),
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
                      child: const Text(
                        'CREATE',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.8),
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