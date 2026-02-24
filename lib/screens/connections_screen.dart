import 'package:flutter/material.dart';
import 'package:mqtt_app/screens/panels/add_connection_screen.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Connections',
            style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: _connections.isEmpty ? _buildEmptyState() : _buildConnectionsList(),
      floatingActionButton: _connections.isNotEmpty
          ? Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fab_import',
            onPressed: () {},
            backgroundColor: const Color(0xFF1E88E5),
            shape: const CircleBorder(),
            child: const Icon(Icons.description, color: Colors.white),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'fab_add',
            onPressed: _goToAddConnection,
            backgroundColor: const Color(0xFF1E88E5),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You do not have any connection to communicate with MQTT broker. If you are using this application for the first time, we highly recomend to go through FAQ and User Guide from main menu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 260, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _goToAddConnection,
                child: const Text('SETUP A CONNECTION',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionsList() {
    return ListView.separated(
      itemCount: _connections.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conn = _connections[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(conn['name'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                child: const Icon(Icons.cloud_off, color: Colors.black54, size: 20),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) {
                    if (value == 'delete') _deleteConnection(index);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen(connection: conn, connectionIndex: index, dashboardIndex: 0)),
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
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 200, color: Colors.white,
            alignment: Alignment.center,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 30),
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: const _HouseWifiIcon(),
              ),
            ]),
          ),
          const Divider(height: 1),
          _DrawerItem(icon: Icons.list, label: 'All Connections', onTap: () => Navigator.pop(context)),
          const Divider(height: 1),
          _DrawerItem(icon: Icons.settings_outlined, label: 'App Settings', onTap: () => Navigator.pop(context)),
          const Divider(height: 1),
          _DrawerItem(icon: Icons.sync, label: 'Backup and Restore', onTap: () => Navigator.pop(context)),
          const Divider(height: 1),
          _DrawerItem(icon: Icons.help_outline, label: 'Help and FAQ', onTap: () => Navigator.pop(context)),
          const Divider(height: 1),
          _DrawerItem(icon: Icons.menu_book_outlined, label: 'User Guide', onTap: () => Navigator.pop(context)),
          const Divider(height: 1),
          _DrawerItem(icon: Icons.info_outline, label: 'About', onTap: () => Navigator.pop(context)),
          const Divider(height: 1),
          _DrawerItem(icon: Icons.exit_to_app, label: 'Exit', onTap: () => Navigator.pop(context)),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Colors.black54, size: 22),
    title: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
  );
}

class _HouseWifiIcon extends StatelessWidget {
  const _HouseWifiIcon();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _HouseWifiPainter());
}

class _HouseWifiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roofPaint = Paint()..color = const Color(0xFFB71C1C)..style = PaintingStyle.fill;
    final wallPaint = Paint()..color = Colors.grey.shade300..style = PaintingStyle.fill;
    final wifiPaint = Paint()..color = const Color(0xFF1E88E5)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = const Color(0xFF1E88E5)..style = PaintingStyle.fill;
    final w = size.width; final h = size.height;
    canvas.drawRect(Rect.fromLTWH(w*0.15, h*0.45, w*0.7, h*0.45), wallPaint);
    canvas.drawPath(Path()..moveTo(w*0.5,h*0.08)..lineTo(w*0.88,h*0.48)..lineTo(w*0.12,h*0.48)..close(), roofPaint);
    final center = Offset(w*0.5, h*0.72);
    for (final d in [0.5, 0.32, 0.14]) {
      canvas.drawArc(Rect.fromCenter(center: center, width: w*d, height: w*d), 3.14+0.5, 2.14, false, wifiPaint);
    }
    canvas.drawCircle(center, 4, dotPaint);
  }
  @override bool shouldRepaint(_) => false;
}