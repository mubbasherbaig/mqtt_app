import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'app_settings.dart';

class AddConnectionScreen extends StatefulWidget {
  const AddConnectionScreen({super.key});

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _clientIdController  = TextEditingController();
  final _brokerController    = TextEditingController();
  final _portController      = TextEditingController(text: '1883');
  final _usernameController  = TextEditingController();
  final _passwordController  = TextEditingController();

  String _selectedProtocol = 'TCP';
  final List<String> _protocols = ['TCP', 'WebSocket', 'SSL/TLS'];
  final List<Map<String, String>> _dashboards = [];
  bool _dashboardError = false;

  @override
  void dispose() {
    _clientIdController.dispose();
    _brokerController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _addDashboard(AppLocalizations l) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        bool setAsHome   = true;
        String? nameError;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.addDashboard,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      onChanged: (_) {
                        if (nameError != null) setDialogState(() => nameError = null);
                      },
                      decoration: InputDecoration(
                        hintText: l.dashboardName,
                        hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
                        errorText: nameError,
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                        errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => setDialogState(() => setAsHome = !setAsHome),
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: setAsHome,
                            activeColor: const Color(0xFF1E88E5),
                            onChanged: (v) => setDialogState(() => setAsHome = v!),
                          ),
                          Text(l.setAsHome,
                              style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120, height: 42,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(l.cancel,
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120, height: 42,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: () {
                              if (controller.text.trim().isEmpty) {
                                setDialogState(() => nameError = l.required);
                                return;
                              }
                              setState(() {
                                _dashboards.add({'name': controller.text.trim(), 'isHome': setAsHome.toString()});
                                _dashboardError = false;
                              });
                              Navigator.pop(context);
                            },
                            child: Text(l.save,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _create(AppLocalizations l) {
    if (_dashboards.isEmpty) setState(() => _dashboardError = true);
    final formValid = _formKey.currentState!.validate();
    if (_dashboards.isEmpty || !formValid) return;

    Navigator.pop(context, {
      'name':       _dashboards.first['name'] ?? '',
      'clientId':   _clientIdController.text,
      'broker':     _brokerController.text,
      'port':       _portController.text,
      'protocol':   _selectedProtocol,
      'username':   _usernameController.text,
      'password':   _passwordController.text,
      'dashboards': _dashboards,
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l        = AppLocalizations.of(settings.languageCode);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.addConnection,
            style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildField(controller: _clientIdController, label: l.clientId, required: false,
                tooltip: 'Unique client identifier. Leave blank to auto-generate.'),
            const SizedBox(height: 20),
            _buildField(controller: _brokerController, label: l.brokerAddress, required: true,
                tooltip: 'IP address or hostname of your MQTT broker.',
                validator: (v) => v == null || v.isEmpty ? l.required : null),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(flex: 2, child: _buildPortField(l)),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: _buildProtocolDropdown(l)),
            ]),
            const SizedBox(height: 28),

            // Add Dashboard row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${l.addDashboard} *',
                      style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  if (_dashboardError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(l.required,
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ]),
                GestureDetector(
                  onTap: () => _addDashboard(l),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),

            if (_dashboards.isNotEmpty) ...[
              const SizedBox(height: 10),
              ..._dashboards.map((d) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dashboard_outlined, color: Colors.blueGrey),
                title: Text(d['name'] ?? ''),
                trailing: d['isHome'] == 'true'
                    ? Chip(label: Text(l.home, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero)
                    : null,
              )),
            ],

            const SizedBox(height: 20),

            // Additional options
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(l.additionalOptions,
                    style: const TextStyle(fontSize: 16, color: Colors.black87)),
                trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                children: [_buildAdditionalOptions(l)],
              ),
            ),
            const SizedBox(height: 30),

            // CANCEL / CREATE
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 130, height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.cancel,
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(width: 130, height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () => _create(l),
                  child: Text(l.create,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required bool required,
    String? tooltip,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              labelText: required ? '$label *' : label,
              labelStyle: const TextStyle(color: Colors.black54, fontSize: 16),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            ),
          ),
        ),
        if (tooltip != null) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: tooltip,
            child: Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
              child: const Icon(Icons.question_mark, color: Colors.white, size: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPortField(AppLocalizations l) {
    return TextFormField(
      controller: _portController,
      keyboardType: TextInputType.number,
      validator: (v) => v == null || v.isEmpty ? l.required : null,
      decoration: InputDecoration(
        labelText: '${l.port} *',
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 16),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
      ),
    );
  }

  Widget _buildProtocolDropdown(AppLocalizations l) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedProtocol,
            decoration: InputDecoration(
              labelText: l.networkProtocol,
              labelStyle: const TextStyle(color: Colors.black54, fontSize: 16),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
            ),
            items: _protocols.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => _selectedProtocol = v!),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
          child: const Icon(Icons.question_mark, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _buildAdditionalOptions(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: l.username,
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l.password,
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}