import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'app_settings.dart';
import 'select_panel_screen.dart';
import '../services/storage_service.dart';

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

  @override
  void initState() {
    super.initState();
    _panels = StorageService.getPanels(widget.connectionIndex, widget.dashboardIndex);
  }

  Future<void> _addPanel() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SelectPanelScreen()),
    );
    if (result != null) {
      await StorageService.addPanel(widget.connectionIndex, widget.dashboardIndex, result);
      setState(() {
        _panels = StorageService.getPanels(widget.connectionIndex, widget.dashboardIndex);
      });
    }
  }

  Future<void> _deletePanel(int index) async {
    await StorageService.deletePanel(widget.connectionIndex, widget.dashboardIndex, index);
    setState(() {
      _panels = StorageService.getPanels(widget.connectionIndex, widget.dashboardIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);

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
          _connectionName,
          style: const TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: Colors.grey.shade200, shape: BoxShape.circle),
            child: const Icon(Icons.cloud_off, color: Colors.black54, size: 20),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: Colors.grey.shade200, shape: BoxShape.circle),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) {
                if (value == 'add_panel') _addPanel();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'add_panel', child: Text(l.addPanel)),
                PopupMenuItem(
                    value: 'settings', child: Text(l.connectionSettings)),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: _panels.isEmpty ? _buildEmptyState(l) : _buildPanelsList(l),
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Current dashboard does not have any panel',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200, height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: _addPanel,
              child: Text(
                l.addPanel.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelsList(AppLocalizations l) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _panels.length,
      itemBuilder: (context, index) {
        final panel = _panels[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(_getPanelIcon(panel['type']),
                color: const Color(0xFF1E88E5)),
            title: Text(panel['panelName'] ?? panel['type'] ?? 'Panel'),
            subtitle: panel['topic'] != null &&
                panel['topic'].toString().isNotEmpty
                ? Text('${l.topic}: ${panel['topic']}')
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deletePanel(index),
            ),
          ),
        );
      },
    );
  }

  IconData _getPanelIcon(String? type) {
    switch (type) {
      case 'Button':               return Icons.crop_square;
      case 'Switch':               return Icons.toggle_on;
      case 'Slider':               return Icons.linear_scale;
      case 'Text Input':           return Icons.chat_bubble_outline;
      case 'Text Output':          return Icons.notes;
      case 'Node Status':          return Icons.wifi_tethering;
      case 'LED Indicator':        return Icons.notifications;
      case 'Gauge':                return Icons.speed;
      case 'Line Graph':           return Icons.show_chart;
      case 'Bar Graph':            return Icons.bar_chart;
      case 'Chart':                return Icons.pie_chart;
      default:                     return Icons.dashboard;
    }
  }
}