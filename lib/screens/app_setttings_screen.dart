// lib/screens/app_setttings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'app_localizations.dart';
import 'app_settings.dart';
import '../services/storage_service.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  // Load real connections once so the Default Connection dropdown is populated
  late List<Map<String, dynamic>> _connections;

  @override
  void initState() {
    super.initState();
    _connections = StorageService.loadConnections();
  }

  // Opens Android battery optimization settings via platform channel
  Future<void> _openBatterySettings() async {
    const channel = MethodChannel('com.upgrade.mqtt_app/battery');
    try {
      await channel.invokeMethod('openBatterySettings');
    } catch (_) {
      // Channel not yet implemented — show a snackbar instead
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Go to: Settings → Apps → This App → Battery → Unrestricted',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l = AppLocalizations.of(settings.languageCode);

    // Build connection map for Default Connection dropdown
    // Key = connection name, always starts with 'none'
    final connectionItems = <String, String>{'none': 'none'};
    for (final conn in _connections) {
      final name = (conn['name'] as String? ?? '').trim();
      if (name.isNotEmpty) connectionItems[name] = name;
    }

    // Guard: if saved default was deleted, fall back to 'none'
    final safeDefault = connectionItems.containsKey(settings.defaultConnection)
        ? settings.defaultConnection
        : 'none';

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
          l.appSettings,
          style: const TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: ListView(
        children: [

          // ══════════════════════════════════════════════════
          // APPEARANCE
          // ══════════════════════════════════════════════════
          _SectionHeader(l.appearance),

          // Dark theme — instantly switches app theme via main.dart ThemeMode
          _ToggleRow(
            icon: Icons.dark_mode_outlined,
            label: l.darkTheme,
            value: settings.darkTheme,
            onChanged: settings.setDarkTheme,
          ),
          _divider(),

          // Language — instantly re-renders all localized strings
          _DropdownRow<String>(
            icon: Icons.language_outlined,
            label: l.selectLanguage,
            value: settings.languageCode,
            items: {'en': l.english, 'it': l.italian},
            onChanged: settings.setLanguage,
          ),
          _divider(),

          // Screen orientation — calls SystemChrome immediately on change
          _DropdownRow<String>(
            icon: Icons.screen_rotation_outlined,
            label: l.orientation,
            value: settings.orientation,
            items: {'Portrait': l.portrait, 'Landscape': l.landscape},
            onChanged: settings.setOrientation,
          ),
          _divider(),

          // ══════════════════════════════════════════════════
          // BEHAVIOR
          // ══════════════════════════════════════════════════
          _SectionHeader(l.behavior),

          // Keep screen on — enables WakelockPlus immediately
          _ToggleRow(
            icon: Icons.visibility_outlined,
            label: l.keepScreenOn,
            value: settings.keepScreenOn,
            onChanged: settings.setKeepScreenOn,
          ),
          _divider(),

          // Run in background — MultiMqttService reads this flag to decide
          // whether to start the foreground keep-alive service
          // _ToggleRow(
          //   icon: Icons.sync_outlined,
          //   label: l.runInBackground,
          //   value: settings.runInBackground,
          //   onChanged: settings.setRunInBackground,
          // ),
          // _divider(),

          // Disable battery optimization — opens Android system settings
          // The toggle turns on → opens settings page → user whitelists app
          // The toggle turns off → just saves the preference (can't re-enable)
          _ToggleRow(
            icon: Icons.battery_saver_outlined,
            label: l.disableBatteryOptimization,
            value: settings.disableBatteryOpt,
            onChanged: (v) async {
              await settings.setDisableBatteryOpt(v);
              if (v) await _openBatterySettings();
            },
          ),
          _divider(),

          // ══════════════════════════════════════════════════
          // DASHBOARD
          // ══════════════════════════════════════════════════
          // _SectionHeader(l.dashboardSettings),
          //
          // // Dashboard tab bar placement — Bottom Bar or Side Bar
          // // DashboardScreen reads settings.dashboardPlacement to decide layout
          // _DropdownRow<String>(
          //   icon: Icons.dashboard_outlined,
          //   label: l.dashboardListPlacement,
          //   value: settings.dashboardPlacement,
          //   items: {'Bottom Bar': l.bottomBar, 'Side Bar': l.sideBar},
          //   onChanged: settings.setDashboardPlacement,
          // ),
          // _divider(),
          //
          // // Default connection — populated from real saved connections
          // // ConnectionsScreen reads settings.defaultConnection in initState
          // // and auto-opens that connection if it's not 'none'
          // _DropdownRow<String>(
          //   icon: Icons.wifi_outlined,
          //   label: l.defaultConnection,
          //   value: safeDefault,
          //   items: {
          //     for (final k in connectionItems.keys)
          //       k: k == 'none' ? l.none : k,
          //   },
          //   onChanged: settings.setDefaultConnection,
          // ),
          // _divider(),
          //
          // const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, thickness: 1, indent: 16, color: Color(0xFFE0E0E0));
}

// ─────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E88E5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Toggle row
// ─────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54, size: 22),
      title: Text(label,
          style: const TextStyle(fontSize: 15, color: Colors.black87)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E88E5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dropdown row
// ─────────────────────────────────────────────────────────────
class _DropdownRow<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T value;
  final Map<T, String> items; // key → display label
  final ValueChanged<T> onChanged;

  const _DropdownRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = items.containsKey(value) ? value : items.keys.first;
    return ListTile(
      leading: Icon(icon, color: Colors.black54, size: 22),
      title: Text(label,
          style: const TextStyle(fontSize: 15, color: Colors.black87)),
      trailing: DropdownButton<T>(
        value: safeValue,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        items: items.entries
            .map((e) => DropdownMenuItem<T>(
          value: e.key,
          child: Text(e.value),
        ))
            .toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}