import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'app_settings.dart';
import 'select_panel_screen.dart';
import '../services/storage_service.dart';
import '../services/mqtt_service.dart';
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

// ─────────────────────────────────────────────────────────────
// DashboardScreen — multi-dashboard host with bottom tab bar
// ─────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> connection;
  final int connectionIndex;
  /// Which dashboard tab to open initially (default 0 = home dashboard).
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

  String get _connectionName => _connection['name'] ?? 'Dashboard';

  // Keep a mutable copy of the connection data so we can update dashboards.
  late Map<String, dynamic> _connection;

  @override
  void initState() {
    super.initState();
    _connection = Map<String, dynamic>.from(widget.connection);
    _dashboards = StorageService.getDashboards(widget.connectionIndex);
    _currentTab = widget.dashboardIndex.clamp(0, _dashboards.isEmpty ? 0 : _dashboards.length - 1);
  }

  void _reloadDashboards() {
    final connections = StorageService.loadConnections();
    if (widget.connectionIndex < connections.length) {
      _connection = connections[widget.connectionIndex];
    }
    _dashboards = StorageService.getDashboards(widget.connectionIndex);
    // Clamp current tab to valid range
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    // ── Icon + Name row ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Icon picker button
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
                              color: const Color(0xFF1E88E5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF1E88E5).withOpacity(0.4)),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(selectedIcon,
                                      size: 26,
                                      color: const Color(0xFF1E88E5)),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1E88E5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit,
                                        size: 8, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name field
                        Expanded(
                          child: TextField(
                            controller: controller,
                            autofocus: true,
                            onChanged: (_) {
                              if (nameError != null) {
                                setDialogState(() => nameError = null);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: l.dashboardName,
                              hintStyle: const TextStyle(
                                  color: Colors.black38, fontSize: 16),
                              errorText: nameError,
                              enabledBorder: const UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.black26)),
                              focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color(0xFF1E88E5))),
                              errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () =>
                          setDialogState(() => setAsHome = !setAsHome),
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: setAsHome,
                            activeColor: const Color(0xFF1E88E5),
                            onChanged: (v) =>
                                setDialogState(() => setAsHome = v!),
                          ),
                          Text(l.setAsHome,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(l.cancel,
                              style:
                              const TextStyle(color: Colors.black54)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            final name = controller.text.trim();
                            if (name.isEmpty) {
                              setDialogState(() => nameError = l.required);
                              return;
                            }
                            Navigator.pop(dialogContext, {
                              'name': name,
                              'icon': iconToString(selectedIcon),
                              'isHome': setAsHome.toString(),
                              'panels': <Map<String, dynamic>>[],
                            });
                          },
                          child: Text(l.create,
                              style: const TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontWeight: FontWeight.w600)),
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
      final newIndex =
      await StorageService.addDashboard(widget.connectionIndex, result);
      setState(() {
        _reloadDashboards();
        if (newIndex >= 0) _currentTab = newIndex;
      });
    }
  }

  // ── Delete current dashboard ──────────────────────────────

  Future<void> _deleteCurrentDashboard(AppLocalizations l) async {
    if (_dashboards.length <= 1) {
      // Must have at least one dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l.cannotDeleteLastDashboard),
            duration: const Duration(seconds: 2)),
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
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.delete,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteDashboard(
          widget.connectionIndex, _currentTab);
      setState(() {
        _reloadDashboards();
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);
    final mqtt = context.watch<MqttService>();

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
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Live connection status indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: _MqttStatusChip(state: mqtt.connectionState),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.grey.shade200, shape: BoxShape.circle),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
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
                    final conn = _connection;
                    context.read<MqttService>().connect(
                      host: conn['broker'] ?? '',
                      port: int.tryParse(
                          conn['port']?.toString() ?? '1883') ??
                          1883,
                      clientId: conn['clientId'] ?? '',
                      username: conn['username'] ?? '',
                      password: conn['password'] ?? '',
                    );
                    break;
                  case 'disconnect':
                    context.read<MqttService>().disconnect();
                    break;
                  case 'settings':
                  // TODO: navigate to connection settings
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'add_panel', child: Text(l.addPanel)),
                PopupMenuItem(
                    value: 'add_dashboard',
                    child: Text(l.addANewDashboard)),
                if (hasDashboards && _dashboards.length > 1)
                  PopupMenuItem(
                      value: 'delete_dashboard',
                      child: Text(l.deleteThisDashboard,
                          style: const TextStyle(color: Colors.red))),
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
      // ── Body: current dashboard panels ──
      body: hasDashboards
          ? _DashboardTabBody(
        key: ValueKey('dashboard_${widget.connectionIndex}_$_currentTab'),
        connectionIndex: widget.connectionIndex,
        dashboardIndex: _currentTab,
        dashboardName: currentDashboardName,
      )
          : _buildNoDashboardsState(l),
      // ── Bottom dashboard tab bar ──
      bottomNavigationBar: hasDashboards && _dashboards.length > 1
          ? _DashboardTabBar(
        dashboards: _dashboards,
        currentIndex: _currentTab,
        onTabSelected: (i) => setState(() => _currentTab = i),
      )
          : null,
      floatingActionButton: hasDashboards
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        mini: true,
        onPressed: _addPanel,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  // ── Add panel to current dashboard ───────────────────────

  Future<void> _addPanel() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SelectPanelScreen()),
    );
    if (result != null) {
      await StorageService.addPanel(
          widget.connectionIndex, _currentTab, result);
      setState(() {}); // trigger rebuild of _DashboardTabBody via key
    }
  }

  Widget _buildNoDashboardsState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard_outlined, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(l.noDashboards,
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5)),
            onPressed: () {
              final settings = context.read<AppSettings>();
              _showAddDashboardDialog(AppLocalizations.of(settings.languageCode));
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(l.addDashboard,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom tab bar for multiple dashboards — tall with icon + label
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
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
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
            final name = d['name'] as String? ?? 'Dashboard ${i + 1}';
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
                padding: const EdgeInsets.symmetric(horizontal: 18),
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
// Body for a single dashboard tab (panels grid)
// ─────────────────────────────────────────────────────────────

class _DashboardTabBody extends StatefulWidget {
  final int connectionIndex;
  final int dashboardIndex;
  final String dashboardName;

  const _DashboardTabBody({
    super.key,
    required this.connectionIndex,
    required this.dashboardIndex,
    required this.dashboardName,
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
    _reload();
  }

  void _reload() {
    _panels = StorageService.getPanels(
        widget.connectionIndex, widget.dashboardIndex);
  }

  Future<void> _deletePanel(int index) async {
    final settings = context.read<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete panel?'),
        content: const Text('This panel will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.delete,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await StorageService.deletePanel(
          widget.connectionIndex, widget.dashboardIndex, index);
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);
    final mqtt = context.watch<MqttService>();

    if (_panels.isEmpty) {
      return _buildEmptyState(l);
    }
    return _buildPanelGrid(mqtt);
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard_outlined,
              size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(l.noPanels,
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(l.addFirstPanel,
              style: const TextStyle(fontSize: 13, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildPanelGrid(MqttService mqtt) {
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
          mqtt: mqtt,
          onDelete: () => _deletePanel(index),
        );
      },
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
      default:
        color = Colors.red;
        label = 'Offline';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Panel Card wrapper — shows label + live widget + delete
// ─────────────────────────────────────────────────────────────

class _PanelCard extends StatelessWidget {
  final Map<String, dynamic> panel;
  final String dashboardPrefix;
  final MqttService mqtt;
  final VoidCallback onDelete;

  const _PanelCard({
    required this.panel,
    required this.dashboardPrefix,
    required this.mqtt,
    required this.onDelete,
  });

  String _effectiveTopic(String raw) {
    final disable = panel['disableDashboardPrefix'] == true;
    if (disable || dashboardPrefix.isEmpty) return raw;
    return '$dashboardPrefix$raw';
  }

  @override
  Widget build(BuildContext context) {
    final type = panel['type'] as String? ?? '';
    final name =
        panel['panelName'] as String? ?? panel['label'] as String? ?? type;
    final panelIcon = iconFromString(panel['icon'] as String?);

    return Card(
      elevation: 2,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
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
                        color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.close,
                      size: 16, color: Colors.black38),
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

    // Apply dashboard prefix to subscribeTopic as well
    final rawSub = panel['subscribeTopic'] as String? ?? '';
    final enriched = Map<String, dynamic>.from(panel);
    if (rawSub.isNotEmpty) enriched['subscribeTopic'] = _effectiveTopic(rawSub);

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
        return LiveUriLauncherPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Layout Decorator':
        return LiveLayoutDecoratorPanel(panel: enriched);
      default:
        return Center(
            child: Text(type,
                style: const TextStyle(color: Colors.black38)));
    }
  }
}