// lib/screens/connections_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mqtt_app/screens/add_connection_screen.dart';
import '../services/mqtt_service.dart';
import '../services/backup_service.dart';
import 'app_localizations.dart';
import 'app_settings.dart';
import 'app_setttings_screen.dart';
import 'dashboard_screen.dart';
import '../services/storage_service.dart';
import '../services/multi_mqtt_service.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _connections = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connections = StorageService.loadConnections();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MultiMqttService>().resumeAll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _reload();
      context.read<MultiMqttService>().resumeAll();
    }
  }

  void _reload() {
    setState(() => _connections = StorageService.loadConnections());
  }

  Future<void> _goToAddConnection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddConnectionScreen()),
    );
    if (result != null) {
      await StorageService.addConnection(result);
      _reload();
    }
  }

  Future<void> _deleteConnection(int index) async {
    final mqtt = context.read<MultiMqttService>();
    final conn = _connections[index];
    final host = conn['broker'] ?? '';
    final port = int.tryParse(conn['port']?.toString() ?? '1883') ?? 1883;
    await mqtt.disconnectBroker(host, port, intentional: true);
    await StorageService.deleteConnection(index);
    _reload();
  }

  Future<void> _openConnection(
      Map<String, dynamic> conn, int index) async {
    final mqtt = context.read<MultiMqttService>();
    final host     = conn['broker'] ?? '';
    final port     = int.tryParse(conn['port']?.toString() ?? '1883') ?? 1883;
    final clientId = conn['clientId'] ?? '';
    final username = conn['username'] ?? '';
    final password = conn['password'] ?? '';

    if (host.isNotEmpty) {
      mqtt.connectBroker(
        host: host, port: port,
        clientId: clientId, username: username, password: password,
      );
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          connection: conn,
          connectionIndex: index,
          dashboardIndex: 0,
        ),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l        = AppLocalizations.of(settings.languageCode);
    final mqtt     = context.watch<MultiMqttService>();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(onBackupRestored: _reload),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          l.connections,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: _connections.isEmpty
          ? _buildEmptyState(l)
          : _buildConnectionsList(l, mqtt),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        onPressed: _goToAddConnection,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(l.noConnections,
              textAlign: TextAlign.center,
              style:
              const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            onPressed: _goToAddConnection,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(l.addConnection,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(
      AppLocalizations l, MultiMqttService mqtt) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _connections.length,
      separatorBuilder: (_, __) => const Divider(
          height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
      itemBuilder: (context, index) {
        final conn = _connections[index];
        final host =
            conn['broker'] ?? '';
        final port =
            int.tryParse(conn['port']?.toString() ?? '1883') ?? 1883;
        final state = mqtt.getState(host, port);

        return ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(
            conn['name'] ?? '',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '$host:$port',
            style:
            const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ConnectionStatusDot(state: state),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.black87),
                  onSelected: (value) async {
                    if (value == 'delete') {
                      _deleteConnection(index);
                    } else if (value == 'export') {
                      await BackupService.exportConnectionBackup(
                        context,
                        index,
                        conn['name'] ?? 'connection',
                      );
                    } else if (value == 'import') {
                      final ok =
                      await BackupService.importConnectionBackup(
                          context, index);
                      if (ok) _reload();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l.edit)),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(children: [
                        Icon(Icons.upload_outlined,
                            size: 18, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Export Backup'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Row(children: [
                        Icon(Icons.download_outlined,
                            size: 18, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Import Backup'),
                      ]),
                    ),
                    PopupMenuItem(
                        value: 'delete', child: Text(l.delete)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _openConnection(conn, index),
        );
      },
    );
  }
}

// ── Per-connection status dot ──────────────────────────────────
class _ConnectionStatusDot extends StatefulWidget {
  final AppMqttState state;
  const _ConnectionStatusDot({required this.state});

  @override
  State<_ConnectionStatusDot> createState() =>
      _ConnectionStatusDotState();
}

class _ConnectionStatusDotState extends State<_ConnectionStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case AppMqttState.connected:
        return Container(
          width: 12, height: 12,
          decoration: const BoxDecoration(
              color: Colors.green, shape: BoxShape.circle),
        );
      case AppMqttState.connecting:
      case AppMqttState.reconnecting:
        return FadeTransition(
          opacity: _anim,
          child: Container(
            width: 12, height: 12,
            decoration: const BoxDecoration(
                color: Colors.orange, shape: BoxShape.circle),
          ),
        );
      case AppMqttState.error:
        return Container(
          width: 12, height: 12,
          decoration: const BoxDecoration(
              color: Colors.red, shape: BoxShape.circle),
        );
      default:
        return Container(
          width: 12, height: 12,
          decoration: const BoxDecoration(
              color: Colors.black26, shape: BoxShape.circle),
        );
    }
  }
}

// ── Drawer ────────────────────────────────────────────────────
class AppDrawer extends StatelessWidget {
  final VoidCallback? onBackupRestored;
  const AppDrawer({super.key, this.onBackupRestored});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            height: 180,
            color: const Color(0xFF1565C0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(l.appName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: Text(l.allConnections),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l.appSettings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AppSettingsScreen()));
            },
          ),
          const Divider(height: 1),
          // Full backup section
          Padding(
            padding:
            const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Full Backup',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined,
                color: Color(0xFF1E88E5)),
            title: const Text('Export Full Backup'),
            subtitle: const Text('Save all dashboards & panels'),
            onTap: () async {
              Navigator.pop(context);
              await BackupService.exportFullBackup(context);
            },
          ),
          ListTile(
            leading:
            const Icon(Icons.download_outlined, color: Colors.orange),
            title: const Text('Import Full Backup'),
            subtitle: const Text('Restore everything from file'),
            onTap: () async {
              Navigator.pop(context);
              final ok = await BackupService.importFullBackup(context);
              if (ok) onBackupRestored?.call();
            },
          ),
        ],
      ),
    );
  }
}