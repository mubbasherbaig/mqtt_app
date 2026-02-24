import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'app_settings.dart';
import 'select_panel_screen.dart';
import '../services/storage_service.dart';
import '../services/mqtt_service.dart';

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

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> connection;
  final int connectionIndex;
  final int dashboardIndex;

  const DashboardScreen({
    super.key,
    required this.connection,
    required this.connectionIndex,
    required this.dashboardIndex,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _panels = [];

  String get _connectionName => widget.connection['name'] ?? 'Dashboard';

  /// Dashboard-level topic prefix (e.g. "home/dashboard1/")
  String get _dashboardPrefix {
    final dashboards =
        (widget.connection['dashboards'] as List?)?.cast<Map>() ?? [];
    if (widget.dashboardIndex < dashboards.length) {
      final name = dashboards[widget.dashboardIndex]['name'] ?? '';
      return name.isEmpty ? '' : '$name/';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _panels =
        StorageService.getPanels(widget.connectionIndex, widget.dashboardIndex);
  }

  Future<void> _addPanel() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SelectPanelScreen()),
    );
    if (result != null) {
      await StorageService.addPanel(
          widget.connectionIndex, widget.dashboardIndex, result);
      setState(_reload);
    }
  }

  Future<void> _deletePanel(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete panel?'),
        content: const Text('This panel will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
              const Text('Delete', style: TextStyle(color: Colors.red))),
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
            decoration:
            BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) {
                if (value == 'add_panel') _addPanel();
                if (value == 'disconnect') {
                  context.read<MqttService>().disconnect();
                }
                if (value == 'reconnect') {
                  final conn = widget.connection;
                  context.read<MqttService>().connect(
                    host: conn['broker'] ?? '',
                    port: int.tryParse(
                        conn['port']?.toString() ?? '1883') ??
                        1883,
                    clientId: conn['clientId'] ?? '',
                    username: conn['username'] ?? '',
                    password: conn['password'] ?? '',
                  );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'add_panel', child: Text(l.addPanel)),
                PopupMenuItem(
                    value: 'reconnect',
                    child: const Text('Reconnect')),
                PopupMenuItem(
                    value: 'disconnect',
                    child: const Text('Disconnect')),
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
      body: _panels.isEmpty
          ? _buildEmptyState(l)
          : _buildPanelGrid(mqtt),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        mini: true,
        onPressed: _addPanel,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard_outlined, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(l.noPanels,
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(l.addFirstPanel,
              style: const TextStyle(fontSize: 13, color: Colors.black38)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            onPressed: _addPanel,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(l.addPanel,
                style: const TextStyle(color: Colors.white)),
          ),
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
    final name = panel['panelName'] as String? ?? panel['label'] as String? ?? type;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
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
                  child: const Icon(Icons.close, size: 16, color: Colors.black38),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Live panel widget
            Expanded(
              child: _buildLiveWidget(type),
            ),
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
        return LiveSwitchPanel(panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Text Output':
        return LiveTextOutputPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Text Input':
        return LiveTextInputPanel(panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Slider':
        return LiveSliderPanel(panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Node Status':
        return LiveNodeStatusPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'LED Indicator':
        return LiveLedIndicatorPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Multi-State Indicator':
        return LiveMultiStateIndicatorPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Combo Box':
        return LiveComboBoxPanel(panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Radio Buttons':
        return LiveRadioButtonsPanel(panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Progress':
        return LiveProgressPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Gauge':
        return LiveGaugePanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Line Graph':
        return LiveLineGraphPanel(panel: enriched, dashboardPrefix: dashboardPrefix, mqtt: mqtt);
      case 'Bar Graph':
        return LiveBarGraphPanel(panel: enriched, dashboardPrefix: dashboardPrefix, mqtt: mqtt);
      case 'Chart':
        return LiveChartPanel(panel: enriched, dashboardPrefix: dashboardPrefix, mqtt: mqtt);
      case 'Color Picker':
        return LiveColorPickerPanel(panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Date & Time Picker':
        return LiveDateTimePickerPanel(panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'Image':
        return LiveImagePanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Barcode Scanner':
        return LiveBarcodeScannerPanel(panel: enriched, topic: topic, mqtt: mqtt, qos: qos);
      case 'URI Launcher':
        return LiveUriLauncherPanel(panel: enriched, topic: topic, mqtt: mqtt);
      case 'Layout Decorator':
        return LiveLayoutDecoratorPanel(panel: enriched);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconFor(type), size: 32, color: const Color(0xFF1E88E5)),
              const SizedBox(height: 6),
              Text(type,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center),
            ],
          ),
        );
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'Button':        return Icons.crop_square;
      case 'Switch':        return Icons.toggle_on;
      case 'Slider':        return Icons.linear_scale;
      case 'Text Input':    return Icons.chat_bubble_outline;
      case 'Text Output':   return Icons.notes;
      case 'Node Status':   return Icons.wifi_tethering;
      case 'LED Indicator': return Icons.notifications;
      case 'Gauge':         return Icons.speed;
      case 'Line Graph':    return Icons.show_chart;
      case 'Bar Graph':     return Icons.bar_chart;
      case 'Chart':         return Icons.pie_chart;
      default:              return Icons.dashboard;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// MQTT status chip shown in AppBar
// ─────────────────────────────────────────────────────────────
class _MqttStatusChip extends StatelessWidget {
  final AppMqttState state;
  const _MqttStatusChip({required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (state) {
      case AppMqttState.connected:
        color = Colors.green;
        label = 'Connected';
        break;
      case AppMqttState.connecting:
        color = Colors.orange;
        label = 'Connecting…';
        break;
      case AppMqttState.error:
        color = Colors.red;
        label = 'Error';
        break;
      default:
        color = Colors.grey;
        label = 'Offline';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}