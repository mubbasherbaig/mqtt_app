import 'package:flutter/material.dart';
import 'package:mqtt_app/screens/panels/barcode_scannner_panel.dart';
import 'package:mqtt_app/screens/panels/date_time_picker.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';
import 'app_localizations.dart';
import 'app_settings.dart';
import 'select_panel_screen.dart';
import '../services/storage_service.dart';
import '../services/multi_mqtt_service.dart';
import '../services/mqtt_service_proxy.dart';
import '../services/backup_service.dart';
import 'widgets/icon_picker_sheet.dart';

// ── Live panel widgets ──────────────────────────────────────
import 'live_panels/live_button_panel.dart';
import 'live_panels/live_switch_panel.dart';
import 'live_panels/live_text_output_panel.dart';
import 'live_panels/live_text_input_panel.dart';
import 'live_panels/live_slider_panel.dart';
import 'live_panels/live_node_status_panel.dart';
import 'live_panels/live_led_indicator_panel.dart';
import 'live_panels/live_multi_state_indicator_panel.dart';
import 'live_panels/live_combo_box_panel.dart';
import 'live_panels/live_radio_buttons_panel.dart';
import 'live_panels/live_progress_panel.dart';
import 'live_panels/live_gauge_panel.dart';
import 'live_panels/live_line_graph_panel.dart';
import 'live_panels/live_bar_graph_panel.dart';
import 'live_panels/live_chart_panel.dart';
import 'live_panels/live_color_picker_panel.dart';
import 'live_panels/live_date_time_picker_panel.dart';
import 'live_panels/live_image_panel.dart';
import 'live_panels/live_barcode_scanner_panel.dart';
import 'live_panels/live_uri_launcher_panel.dart';
import 'live_panels/live_layout_decorator_panel.dart';

import 'panels/button_panel.dart';
import 'panels/switch_panel.dart';
import 'panels/slider_panel.dart';
import 'panels/text_input_panel.dart';
import 'panels/text_output_panel.dart';
import 'panels/node_status_panel.dart';
import 'panels/led_indicator_panel.dart';
import 'panels/multi_state_indicator_panel.dart';
import 'panels/combo_box_panel.dart';
import 'panels/radio_buttons_panel.dart';
import 'panels/progress_panel.dart';
import 'panels/gauge_panel.dart';
import 'panels/line_graph_panel.dart';
import 'panels/bar_graph_panel.dart';
import 'panels/chart_panel.dart';
import 'panels/color_picker_panel.dart';
import 'panels/image_panel.dart';
import 'panels/uri_launcher_panel.dart';
import 'panels/layout_decorator_panel.dart';

// ─────────────────────────────────────────────────────────────
// DashboardScreen
// ─────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> connection;
  final int connectionIndex;
  final int dashboardIndex;

  const DashboardScreen({
    super.key,
    required this.connection,
    required this.connectionIndex,
    this.dashboardIndex = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentTab;
  late List<Map<String, dynamic>> _dashboards;
  late Map<String, dynamic> _connection;

  String get _connectionName => _connection['name'] ?? 'Dashboard';
  String get _connHost => _connection['broker'] ?? '';
  int get _connPort =>
      int.tryParse(_connection['port']?.toString() ?? '1883') ?? 1883;

  @override
  void initState() {
    super.initState();
    _connection = Map<String, dynamic>.from(widget.connection);
    _dashboards = StorageService.getDashboards(widget.connectionIndex);
    _currentTab = widget.dashboardIndex.clamp(
      0,
      _dashboards.isEmpty ? 0 : _dashboards.length - 1,
    );
  }

  void _reloadDashboards() {
    final connections = StorageService.loadConnections();
    if (widget.connectionIndex < connections.length) {
      _connection = connections[widget.connectionIndex];
    }
    _dashboards = StorageService.getDashboards(widget.connectionIndex);
    if (_dashboards.isNotEmpty && _currentTab >= _dashboards.length) {
      _currentTab = _dashboards.length - 1;
    }
  }

  // ── Add dashboard ─────────────────────────────────────────

  Future<void> _showAddDashboardDialog(AppLocalizations l) async {
    final controller = TextEditingController();
    String? nameError;
    IconData selectedIcon = Icons.dashboard_outlined;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        bool setAsHome = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.addDashboard,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final icon = await showIconPicker(
                              dialogContext,
                              current: selectedIcon,
                            );
                            if (icon != null) {
                              setDialogState(() => selectedIcon = icon);
                            }
                          },
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border:
                              Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              selectedIcon,
                              color: const Color(0xFF1E88E5),
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: l.dashboardName,
                              errorText: nameError,
                              border: const UnderlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: setAsHome,
                          onChanged: (v) => setDialogState(
                                  () => setAsHome = v ?? false),
                        ),
                        Text(l.setAsHome),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(l.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            if (controller.text.trim().isEmpty) {
                              setDialogState(
                                      () => nameError = l.required);
                              return;
                            }
                            Navigator.pop(dialogContext, {
                              'name': controller.text.trim(),
                              'icon':
                              selectedIcon.codePoint.toString(),
                              'setAsHome': setAsHome,
                            });
                          },
                          child: Text(l.create),
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

    if (result != null) {
      await StorageService.addDashboard(widget.connectionIndex, result);
      setState(() => _reloadDashboards());
    }
  }

  // ── Delete dashboard ──────────────────────────────────────

  Future<void> _deleteCurrentDashboard(AppLocalizations l) async {
    if (_dashboards.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.cannotDeleteLastDashboard),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteThisDashboard),
        content: Text(l.deleteThisDashboardConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
            Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await StorageService.deleteDashboard(
          widget.connectionIndex, _currentTab);
      setState(() => _reloadDashboards());
    }
  }

  // ── Add panel ─────────────────────────────────────────────

  Future<void> _addPanel() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SelectPanelScreen()),
    );
    if (result != null) {
      await StorageService.addPanel(
        widget.connectionIndex,
        _currentTab,
        result,
      );
      setState(() => _reloadDashboards());
    }
  }

  // ── Duplicate current dashboard ──────────────────────────

  Future<void> _duplicateCurrentDashboard() async {
    if (_dashboards.isEmpty) return;

    final current = _dashboards[_currentTab];
    final originalName = current['name'] as String? ?? 'Dashboard';
    final icon = current['icon'] ?? Icons.dashboard_outlined.codePoint.toString();

    // Copy all panels from current dashboard
    final originalPanels = StorageService.getPanels(
      widget.connectionIndex,
      _currentTab,
    );
    final copiedPanels = originalPanels
        .map((p) => Map<String, dynamic>.from(p))
        .toList();

    // Build new dashboard map with panels already inside
    final newDashboard = <String, dynamic>{
      'name': '$originalName Copy',
      'icon': icon,
      'setAsHome': false,
      'panels': copiedPanels,
    };

    final newIndex = await StorageService.addDashboard(
      widget.connectionIndex,
      newDashboard,
    );

    setState(() {
      _reloadDashboards();
      if (newIndex >= 0) _currentTab = newIndex;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '"$originalName" duplicated as "$originalName Copy" with ${copiedPanels.length} panel(s).'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Backup bottom sheet ───────────────────────────────────

  void _showBackupSheet(AppLocalizations l) {
    final connName = _connectionName;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Backup & Restore',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 20),
            ListTile(
              leading: const Icon(Icons.upload_outlined,
                  color: Color(0xFF1E88E5)),
              title: const Text('Export Backup'),
              subtitle:
              Text('Save dashboards & panels for "$connName"'),
              onTap: () async {
                Navigator.pop(context);
                await BackupService.exportConnectionBackup(
                  context,
                  widget.connectionIndex,
                  connName,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined,
                  color: Colors.orange),
              title: const Text('Import Backup'),
              subtitle:
              const Text('Restore dashboards & panels from file'),
              onTap: () async {
                Navigator.pop(context);
                final ok = await BackupService.importConnectionBackup(
                  context,
                  widget.connectionIndex,
                );
                if (ok && mounted) setState(() => _reloadDashboards());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);
    final multiMqtt = context.watch<MultiMqttService>();
    final connState = multiMqtt.getState(_connHost, _connPort);

    final hasDashboards = _dashboards.isNotEmpty;
    final currentDashboardName = hasDashboards
        ? (_dashboards[_currentTab]['name'] as String? ?? '')
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _connectionName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: _MqttStatusChip(state: connState),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon:
              const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) async {
                switch (value) {
                  case 'add_panel':
                    if (hasDashboards) _addPanel();
                    break;
                  case 'add_dashboard':
                    await _showAddDashboardDialog(l);
                    break;
                  case 'delete_dashboard':
                    await _deleteCurrentDashboard(l);
                    break;
                  case 'reconnect':
                    context.read<MultiMqttService>().connectBroker(
                      host: _connHost,
                      port: _connPort,
                      clientId: _connection['clientId'] ?? '',
                      username: _connection['username'] ?? '',
                      password: _connection['password'] ?? '',
                    );
                    break;
                  case 'disconnect':
                    context
                        .read<MultiMqttService>()
                        .disconnectBroker(
                      _connHost,
                      _connPort,
                      intentional: false,
                    );
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'add_panel', child: Text(l.addPanel)),
                PopupMenuItem(
                  value: 'add_dashboard',
                  child: Text(l.addANewDashboard),
                ),
                if (hasDashboards && _dashboards.length > 1)
                  PopupMenuItem(
                    value: 'delete_dashboard',
                    child: Text(
                      l.deleteThisDashboard,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'reconnect', child: Text('Reconnect')),
                const PopupMenuItem(
                    value: 'disconnect', child: Text('Disconnect')),
                PopupMenuItem(
                    value: 'settings',
                    child: Text(l.connectionSettings)),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: hasDashboards
          ? _DashboardTabBody(
        key: ValueKey(
            'dashboard_${widget.connectionIndex}_$_currentTab'),
        connectionIndex: widget.connectionIndex,
        dashboardIndex: _currentTab,
        dashboardName: currentDashboardName,
        connHost: _connHost,
        connPort: _connPort,
      )
          : _buildNoDashboardsState(l),
      bottomNavigationBar: hasDashboards && _dashboards.length > 1
          ? _DashboardTabBar(
        dashboards: _dashboards,
        currentIndex: _currentTab,
        onTabSelected: (i) => setState(() => _currentTab = i),
      )
          : null,
      // ── FAB row: restore | backup | duplicate | add ──────
      floatingActionButton: hasDashboards
          ? _FabRow(
        onAdd: _addPanel,
        onDuplicate: _duplicateCurrentDashboard,
        onBackup: () => BackupService.exportConnectionBackup(
          context,
          widget.connectionIndex,
          _connectionName,
        ),
        onRestore: () async {
          final ok = await BackupService.importConnectionBackup(
            context,
            widget.connectionIndex,
          );
          if (ok && mounted) setState(() => _reloadDashboards());
        },
      )
          : null,
    );
  }

  Widget _buildNoDashboardsState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard_outlined,
              size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(
            l.noDashboards,
            style:
            const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            onPressed: () {
              final settings = context.read<AppSettings>();
              _showAddDashboardDialog(
                AppLocalizations.of(settings.languageCode),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              l.addDashboard,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FAB Row — four buttons side by side at bottom right
// ─────────────────────────────────────────────────────────────

class _FabRow extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onDuplicate;
  final VoidCallback onBackup;
  final VoidCallback onRestore;

  const _FabRow({
    required this.onAdd,
    required this.onDuplicate,
    required this.onBackup,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Restore button
        Tooltip(
          message: 'Import Backup',
          child: FloatingActionButton(
            heroTag: 'fab_restore',
            mini: true,
            backgroundColor: Colors.orange,
            onPressed: onRestore,
            child: const Icon(Icons.download_outlined,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Backup button
        Tooltip(
          message: 'Export Backup',
          child: FloatingActionButton(
            heroTag: 'fab_backup',
            mini: true,
            backgroundColor: const Color(0xFF43A047),
            onPressed: onBackup,
            child: const Icon(Icons.upload_outlined,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Duplicate dashboard button
        Tooltip(
          message: 'Duplicate Dashboard',
          child: FloatingActionButton(
            heroTag: 'fab_duplicate',
            mini: true,
            backgroundColor: const Color(0xFF8E24AA),
            onPressed: onDuplicate,
            child: const Icon(Icons.copy_all_outlined,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Add panel button (primary)
        Tooltip(
          message: 'Add Panel',
          child: FloatingActionButton(
            heroTag: 'fab_add',
            mini: true,
            backgroundColor: const Color(0xFF1E88E5),
            onPressed: onAdd,
            child:
            const Icon(Icons.add, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MQTT status chip
// ─────────────────────────────────────────────────────────────

class _MqttStatusChip extends StatelessWidget {
  final AppMqttState state;
  const _MqttStatusChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (state) {
      case AppMqttState.connected:
        color = Colors.green;
        label = 'Connected';
        break;
      case AppMqttState.connecting:
        color = Colors.orange;
        label = 'Connecting…';
        break;
      case AppMqttState.reconnecting:
        color = Colors.orange;
        label = 'Reconnecting…';
        break;
      case AppMqttState.error:
        color = Colors.red;
        label = 'Error';
        break;
      default:
        color = Colors.red;
        label = 'Offline';
    }
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom tab bar
// ─────────────────────────────────────────────────────────────

class _DashboardTabBar extends StatelessWidget {
  final List<Map<String, dynamic>> dashboards;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const _DashboardTabBar({
    required this.dashboards,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(dashboards.length, (i) {
            final d = dashboards[i];
            final name =
                d['name'] as String? ?? 'Dashboard ${i + 1}';
            final iconData = iconFromString(d['icon'] as String?);
            final isSelected = i == currentIndex;
            final color = isSelected
                ? const Color(0xFF1E88E5)
                : Colors.black45;
            return GestureDetector(
              onTap: () => onTabSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                constraints: const BoxConstraints(minWidth: 80),
                padding:
                const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isSelected
                          ? const Color(0xFF1E88E5)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  color: isSelected
                      ? const Color(0xFF1E88E5).withOpacity(0.05)
                      : Colors.transparent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconData, size: 22, color: color),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body for a single dashboard tab
// ─────────────────────────────────────────────────────────────

class _DashboardTabBody extends StatefulWidget {
  final int connectionIndex;
  final int dashboardIndex;
  final String dashboardName;
  final String connHost;
  final int connPort;

  const _DashboardTabBody({
    super.key,
    required this.connectionIndex,
    required this.dashboardIndex,
    required this.dashboardName,
    required this.connHost,
    required this.connPort,
  });

  @override
  State<_DashboardTabBody> createState() => _DashboardTabBodyState();
}

class _DashboardTabBodyState extends State<_DashboardTabBody> {
  List<Map<String, dynamic>> _panels = [];

  String get _dashboardPrefix {
    final name = widget.dashboardName;
    return name.isEmpty ? '' : '$name/';
  }

  @override
  void initState() {
    super.initState();
    _loadPanels();
  }

  @override
  void didUpdateWidget(_DashboardTabBody old) {
    super.didUpdateWidget(old);
    if (old.connectionIndex != widget.connectionIndex ||
        old.dashboardIndex != widget.dashboardIndex) {
      _loadPanels();
    }
    _loadPanels();
  }

  void _loadPanels() {
    setState(() {
      _panels = StorageService.getPanels(
        widget.connectionIndex,
        widget.dashboardIndex,
      );
    });
  }

  Future<void> _deletePanel(int index) async {
    await StorageService.deletePanel(
      widget.connectionIndex,
      widget.dashboardIndex,
      index,
    );
    _loadPanels();
  }

  // ── Duplicate panel ───────────────────────────────────────

  Future<void> _duplicatePanel(int index) async {
    final original = Map<String, dynamic>.from(_panels[index]);
    final originalName = original['panelName'] as String? ??
        original['label'] as String? ??
        original['type'] as String? ??
        'Panel';
    original['panelName'] = '$originalName Copy';
    if (original.containsKey('label')) {
      original['label'] = '$originalName Copy';
    }
    await StorageService.addPanel(
      widget.connectionIndex,
      widget.dashboardIndex,
      original,
    );
    _loadPanels();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Panel duplicated'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(int index) async {
    final settings = context.read<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);
    final panelName = _panels[index]['panelName'] as String? ??
        _panels[index]['label'] as String? ??
        _panels[index]['type'] as String? ??
        'Panel';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.delete),
        content: Text('Delete "$panelName"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deletePanel(index);
  }

  Future<void> _editPanel(int index) async {
    final panel = _panels[index];
    final type = panel['type'] as String? ?? '';

    Widget? screen;
    switch (type) {
      case 'Button':
        screen = AddButtonPanelScreen(initialData: panel);
        break;
      case 'Switch':
        screen = AddSwitchPanelScreen(initialData: panel);
        break;
      case 'Slider':
        screen = AddSliderPanelScreen(initialData: panel);
        break;
      case 'Text Input':
        screen = AddTextInputPanelScreen(initialData: panel);
        break;
      case 'Text Output':
        screen = AddTextOutputPanelScreen(initialData: panel);
        break;
      case 'Node Status':
        screen = AddNodeStatusPanelScreen(initialData: panel);
        break;
      case 'LED Indicator':
        screen = AddLedIndicatorPanelScreen(initialData: panel);
        break;
      case 'Multi-State Indicator':
        screen = AddMultiStateIndicatorPanelScreen(initialData: panel);
        break;
      case 'Combo Box':
        screen = AddComboBoxPanelScreen(initialData: panel);
        break;
      case 'Radio Buttons':
        screen = AddRadioButtonsPanelScreen(initialData: panel);
        break;
      case 'Progress':
        screen = AddProgressPanelScreen(initialData: panel);
        break;
      case 'Gauge':
        screen = AddGaugePanelScreen(initialData: panel);
        break;
      case 'Line Graph':
        screen = AddLineGraphPanelScreen(initialData: panel);
        break;
      case 'Bar Graph':
        screen = AddBarGraphPanelScreen(initialData: panel);
        break;
      case 'Chart':
        screen = AddChartPanelScreen(initialData: panel);
        break;
      case 'Color Picker':
        screen = AddColorPickerPanelScreen(initialData: panel);
        break;
      case 'Date & Time Picker':
        screen = AddDateTimePickerPanelScreen(initialData: panel);
        break;
      case 'Image':
        screen = AddImagePanelScreen(initialData: panel);
        break;
      case 'Barcode Scanner':
        screen = AddBarcodeScannerPanelScreen(initialData: panel);
        break;
      case 'URI Launcher':
        screen = AddUriLauncherPanelScreen(initialData: panel);
        break;
      case 'Layout Decorator':
        screen = AddLayoutDecoratorPanelScreen(initialData: panel);
        break;
      default:
        return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => screen!),
    );

    if (result != null) {
      await StorageService.updatePanel(
        widget.connectionIndex,
        widget.dashboardIndex,
        index,
        result,
      );
      _loadPanels();
    }
  }

  @override
  Widget build(BuildContext context) {
    final multiMqtt = context.watch<MultiMqttService>();

    if (_panels.isEmpty) {
      final settings = context.watch<AppSettings>();
      final l = AppLocalizations.of(settings.languageCode);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.widgets_outlined,
                size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            Text(l.noPanels,
                style: const TextStyle(
                    fontSize: 16, color: Colors.black54)),
            Text(l.addFirstPanel,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black38)),
          ],
        ),
      );
    }

    return _buildPanelGrid(multiMqtt);
  }

  Widget _buildPanelGrid(MultiMqttService multiMqtt) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: _panels.length,
      itemBuilder: (context, index) {
        final panel = _panels[index];
        return _PanelCard(
          panel: panel,
          dashboardPrefix: _dashboardPrefix,
          multiMqtt: multiMqtt,
          connHost: widget.connHost,
          connPort: widget.connPort,
          onDelete: () => _showDeleteConfirmation(index),
          onEdit: () => _editPanel(index),
          onDuplicate: () => _duplicatePanel(index),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Panel Card
// ─────────────────────────────────────────────────────────────

class _PanelCard extends StatelessWidget {
  final Map<String, dynamic> panel;
  final String dashboardPrefix;
  final MultiMqttService multiMqtt;
  final String connHost;
  final int connPort;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;

  const _PanelCard({
    required this.panel,
    required this.dashboardPrefix,
    required this.multiMqtt,
    required this.connHost,
    required this.connPort,
    required this.onDelete,
    required this.onEdit,
    required this.onDuplicate,
  });

  String _effectiveTopic(String raw) {
    final disable = panel['disableDashboardPrefix'] == true;
    if (disable || dashboardPrefix.isEmpty) return raw;
    final cleanRaw = raw.startsWith('/') ? raw.substring(1) : raw;
    return '$dashboardPrefix$cleanRaw';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.read<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);
    final type = panel['type'] as String? ?? '';
    final name =
        panel['panelName'] as String? ?? panel['label'] as String? ?? type;
    final panelIcon = iconFromString(panel['icon'] as String?);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(panelIcon, size: 14, color: const Color(0xFF1E88E5)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.more_vert,
                        size: 16, color: Colors.black38),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      else if (value == 'duplicate') onDuplicate();
                      else if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          const Icon(Icons.edit_outlined,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(l.edit),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(children: [
                          const Icon(Icons.copy_outlined,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 8),
                          const Text('Duplicate'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          const Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(l.delete,
                              style: const TextStyle(color: Colors.red)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(child: _buildLiveWidget(type)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveWidget(String type) {
    final rawTopic = panel['topic'] as String? ?? '';
    final topic = _effectiveTopic(rawTopic);
    final qos = int.tryParse(panel['qos']?.toString() ?? '0') ?? 0;
    final rawSub = panel['subscribeTopic'] as String? ?? '';
    final enriched = Map<String, dynamic>.from(panel);
    if (rawSub.isNotEmpty)
      enriched['subscribeTopic'] = _effectiveTopic(rawSub);
    final mqtt = multiMqtt.getProxy(connHost, connPort);

    switch (type) {
      case 'Button':
        return LiveButtonPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Switch':
        return LiveSwitchPanel(
            panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Text Output':
        return LiveTextOutputPanel(
            panel: enriched, topic: topic, mqtt: mqtt);
      case 'Text Input':
        return LiveTextInputPanel(
            panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Slider':
        return LiveSliderPanel(
            panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Node Status':
        return LiveNodeStatusPanel(
            panel: enriched, topic: topic, mqtt: mqtt);
      case 'LED Indicator':
        return LiveLedIndicatorPanel(
            panel: enriched, topic: topic, mqtt: mqtt);
      case 'Multi-State Indicator':
        return LiveMultiStateIndicatorPanel(
            panel: enriched, topic: topic, mqtt: mqtt);
      case 'Combo Box':
        return LiveComboBoxPanel(
            panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Radio Buttons':
        return LiveRadioButtonsPanel(
            panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Progress':
        return LiveProgressPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Gauge':
        return LiveGaugePanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Line Graph':
        return LiveLineGraphPanel(
            panel: enriched,
            dashboardPrefix: dashboardPrefix,
            mqtt: mqtt);
      case 'Bar Graph':
        return LiveBarGraphPanel(
            panel: enriched,
            dashboardPrefix: dashboardPrefix,
            mqtt: mqtt);
      case 'Chart':
        return LiveChartPanel(
            panel: enriched,
            dashboardPrefix: dashboardPrefix,
            mqtt: mqtt);
      case 'Color Picker':
        return LiveColorPickerPanel(
            panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Date Time Picker':
        return LiveDateTimePickerPanel(
            panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Image':
        return LiveImagePanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Barcode Scanner':
        return LiveBarcodeScannerPanel(
            panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'URI Launcher':
        return LiveUriLauncherPanel(
            panel: enriched, topic: topic, mqtt: mqtt);
      case 'Layout Decorator':
        return LiveLayoutDecoratorPanel(panel: enriched);
      default:
        return Center(
            child: Text(type,
                style: const TextStyle(color: Colors.black38)));
    }
  }
}