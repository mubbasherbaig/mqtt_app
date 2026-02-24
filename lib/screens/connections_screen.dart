import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mqtt_app/screens/add_connection_screen.dart';
import 'app_localizations.dart';
import 'app_settings.dart';
import 'app_setttings_screen.dart';
import 'dashboard_screen.dart';
import '../services/storage_service.dart';

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
    await StorageService.deleteConnection(index);
    setState(() => _connections = StorageService.loadConnections());
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);

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
          : _buildConnectionsList(l),
      floatingActionButton: _connections.isNotEmpty
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _goToAddConnection,
      )
          : null,
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            l.noConnections,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _goToAddConnection,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              l.addConnection,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(AppLocalizations l) {
    return ListView.separated(
      itemCount: _connections.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: Color(0xFFE0E0E0)),
      itemBuilder: (context, index) {
        final conn = _connections[index];
        return ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            conn['name'] ?? '',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle),
                child: const Icon(Icons.cloud_off,
                    color: Colors.black54, size: 20),
              ),
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
                  onSelected: (value) {
                    if (value == 'delete') _deleteConnection(index);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit',   child: Text(l.edit)),
                    PopupMenuItem(value: 'delete', child: Text(l.delete)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
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
          },
        );
      },
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
          // Header
          Container(
            height: 200,
            color: Colors.white,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const _HouseWifiIcon(),
                ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AppSettingsScreen()),
              );
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
            icon: Icons.menu_book_outlined,
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

          _DrawerItem(
            icon: Icons.exit_to_app,
            label: l.exit,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ─────────────────────────── Drawer item ───────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 24),
      title: Text(label,
          style: const TextStyle(fontSize: 15, color: Colors.black87)),
      onTap: onTap,
    );
  }
}

// ─────────────────────────── House + Wifi icon ───────────────────────────
class _HouseWifiIcon extends StatelessWidget {
  const _HouseWifiIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.home_outlined, size: 60, color: Color(0xFF1565C0)),
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.wifi,
                size: 22, color: Color(0xFF1565C0)),
          ),
        ),
      ],
    );
  }
}