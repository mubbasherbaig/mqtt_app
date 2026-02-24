import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mqtt_app/screens/add_connection_screen.dart';
import 'app_localizations.dart';
import 'app_settings.dart';
import 'app_setttings_screen.dart';
import 'dashboard_screen.dart';
import '../services/storage_service.dart';
import '../services/mqtt_service.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  List<Map<String, dynamic>> _connections = [];

  @override
  void initState() {
    super.initState();
    _connections = StorageService.loadConnections();
  }

  Future<void> _goToAddConnection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddConnectionScreen()),
    );
    if (result != null) {
      await StorageService.addConnection(result);
      setState(() => _connections = StorageService.loadConnections());
    }
  }

  Future<void> _deleteConnection(int index) async {
    // Disconnect MQTT if this connection is currently active
    final mqtt = context.read<MqttService>();
    final conn = _connections[index];
    if (mqtt.host == (conn['broker'] ?? '') && mqtt.isConnected) {
      await mqtt.disconnect();
    }
    await StorageService.deleteConnection(index);
    setState(() => _connections = StorageService.loadConnections());
  }

  /// Connect to MQTT broker and navigate to dashboard
  Future<void> _openConnection(Map<String, dynamic> conn, int index) async {
    final mqtt = context.read<MqttService>();
    final host = conn['broker'] ?? '';
    final port = int.tryParse(conn['port']?.toString() ?? '1883') ?? 1883;
    final clientId = conn['clientId'] ?? '';
    final username = conn['username'] ?? '';
    final password = conn['password'] ?? '';

    if (host.isNotEmpty) {
      // Connect in background — don't await so UI stays snappy
      mqtt.connect(
        host: host,
        port: port,
        clientId: clientId,
        username: username,
        password: password,
      );
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          connection: conn,
          connectionIndex: index,
          dashboardIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);
    final mqtt = context.watch<MqttService>();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
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
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: _connections.isEmpty
          ? _buildEmptyState(l)
          : _buildConnectionsList(l, mqtt),
      floatingActionButton: _connections.isNotEmpty
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        onPressed: _goToAddConnection,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(
            l.noConnections,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _goToAddConnection,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(l.addConnection,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(AppLocalizations l, MqttService mqtt) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _connections.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
      itemBuilder: (context, index) {
        final conn = _connections[index];
        final isThisConnected =
            mqtt.isConnected && mqtt.host == (conn['broker'] ?? '');
        final isThisConnecting =
            mqtt.connectionState == AppMqttState.connecting &&
                mqtt.host == (conn['broker'] ?? '');

        return ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(
            conn['name'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${conn['broker'] ?? ''}:${conn['port'] ?? '1883'}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Connection status indicator
              _ConnectionStatusDot(
                isConnected: isThisConnected,
                isConnecting: isThisConnecting,
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200, shape: BoxShape.circle),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) {
                    if (value == 'delete') _deleteConnection(index);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l.edit)),
                    PopupMenuItem(value: 'delete', child: Text(l.delete)),
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

// ── Connection status dot ──────────────────────────────────────
class _ConnectionStatusDot extends StatefulWidget {
  final bool isConnected;
  final bool isConnecting;
  const _ConnectionStatusDot(
      {required this.isConnected, required this.isConnecting});

  @override
  State<_ConnectionStatusDot> createState() => _ConnectionStatusDotState();
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
    if (widget.isConnected) {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
            color: Colors.green, shape: BoxShape.circle),
      );
    }
    if (widget.isConnecting) {
      return FadeTransition(
        opacity: _anim,
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
              color: Colors.orange, shape: BoxShape.circle),
        ),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
          color: Colors.black26, shape: BoxShape.circle),
    );
  }
}

// ─────────────────────────── Drawer ───────────────────────────
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 180,
            color: const Color(0xFF1565C0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Icon(Icons.router, size: 64, color: Colors.white70),
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
          _DrawerItem(
            icon: Icons.list,
            label: l.allConnections,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: l.appSettings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AppSettingsScreen()));
            },
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.sync,
            label: l.backupRestore,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.help_outline,
            label: l.helpFaq,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.book_outlined,
            label: l.userGuide,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.info_outline,
            label: l.about,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
          const Spacer(),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.exit_to_app,
            label: l.exit,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}