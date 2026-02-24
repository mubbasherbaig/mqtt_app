import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'app_settings.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

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
          // ── Toggles ─────────────────────────────────────────
          _ToggleRow(
            label: l.darkTheme,
            value: settings.darkTheme,
            onChanged: settings.setDarkTheme,
          ),
          _divider(),
          _ToggleRow(
            label: l.runInBackground,
            value: settings.runInBackground,
            onChanged: settings.setRunInBackground,
          ),
          _divider(),
          _ToggleRow(
            label: l.startOnBoot,
            value: settings.startOnBoot,
            onChanged: settings.setStartOnBoot,
          ),
          _divider(),
          _ToggleRow(
            label: l.disableBatteryOptimization,
            value: settings.disableBatteryOpt,
            onChanged: settings.setDisableBatteryOpt,
          ),
          _divider(),
          _ToggleRow(
            label: l.keepScreenOn,
            value: settings.keepScreenOn,
            onChanged: settings.setKeepScreenOn,
          ),
          _divider(),

          // ── Default Connection ───────────────────────────────
          // Uses fixed internal key 'none', display adapts to language
          _SimpleDropdownRow(
            label: l.defaultConnection,
            value: settings.defaultConnection,
            items: const {'none': 'none'}, // extend later with real connections
            displayBuilder: (key) => key == 'none' ? l.none : key,
            onChanged: settings.setDefaultConnection,
          ),
          _divider(),

          // ── Orientation ──────────────────────────────────────
          // Fixed keys: 'Portrait', 'Landscape' — only display label is translated
          _SimpleDropdownRow(
            label: l.orientation,
            value: settings.orientation,
            items: const {'Portrait': 'Portrait', 'Landscape': 'Landscape'},
            displayBuilder: (key) =>
            key == 'Landscape' ? l.landscape : l.portrait,
            onChanged: settings.setOrientation,
          ),
          _divider(),

          // ── Dashboard placement ──────────────────────────────
          // Fixed keys: 'Bottom Bar', 'Side Bar'
          _SimpleDropdownRow(
            label: l.dashboardListPlacement,
            value: settings.dashboardPlacement,
            items: const {'Bottom Bar': 'Bottom Bar', 'Side Bar': 'Side Bar'},
            displayBuilder: (key) =>
            key == 'Side Bar' ? l.sideBar : l.bottomBar,
            onChanged: settings.setDashboardPlacement,
          ),
          _divider(),

          // ── Language ─────────────────────────────────────────
          // Fixed keys: 'en', 'it' — never change regardless of active language
          _SimpleDropdownRow(
            label: l.selectLanguage,
            value: settings.languageCode,
            items: const {'en': 'en', 'it': 'it'},
            displayBuilder: (key) => key == 'it' ? l.italian : l.english,
            onChanged: settings.setLanguage,
          ),
          _divider(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));
}

// ─────────────────────────────────────────────────────────────
// Toggle row
// ─────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E88E5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dropdown row — fixed internal keys, translated display labels
// ─────────────────────────────────────────────────────────────
class _SimpleDropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> items; // key → key (we only care about keys)
  final String Function(String key) displayBuilder;
  final ValueChanged<String> onChanged;

  const _SimpleDropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.displayBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = items.containsKey(value) ? value : items.keys.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          DropdownButton<String>(
            value: safeValue,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            items: items.keys
                .map((key) => DropdownMenuItem<String>(
              value: key,
              child: Text(displayBuilder(key)),
            ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}