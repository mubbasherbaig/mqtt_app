import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _connectionsKey = 'mqtt_connections';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<Map<String, dynamic>> loadConnections() {
    final raw = _prefs?.getString(_connectionsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<void> saveConnections(
    List<Map<String, dynamic>> connections,
  ) async {
    await _prefs?.setString(_connectionsKey, jsonEncode(connections));
  }

  static Future<void> addConnection(Map<String, dynamic> connection) async {
    final list = loadConnections();
    list.add(connection);
    await saveConnections(list);
  }

  static Future<void> deleteConnection(int index) async {
    final list = loadConnections();
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await saveConnections(list);
    }
  }

  static Future<void> updateConnection(
    int index,
    Map<String, dynamic> updated,
  ) async {
    final list = loadConnections();
    if (index >= 0 && index < list.length) {
      list[index] = updated;
      await saveConnections(list);
    }
  }

  // ── Dashboard-level operations ─────────────────────────────

  /// Returns all dashboards for a connection (live list from storage).
  static List<Map<String, dynamic>> getDashboards(int connectionIndex) {
    final list = loadConnections();
    if (connectionIndex < 0 || connectionIndex >= list.length) return [];
    final conn = list[connectionIndex];
    final dashboards = (conn['dashboards'] as List? ?? []);
    return dashboards
        .map<Map<String, dynamic>>((d) => Map<String, dynamic>.from(d))
        .toList();
  }

  /// Adds a new dashboard to the connection and returns its index.
  static Future<int> addDashboard(
    int connectionIndex,
    Map<String, dynamic> dashboard,
  ) async {
    final list = loadConnections();
    if (connectionIndex < 0 || connectionIndex >= list.length) return -1;
    final conn = Map<String, dynamic>.from(list[connectionIndex]);
    final dashboards = List<Map<String, dynamic>>.from(
      (conn['dashboards'] as List? ?? []).map(
        (d) => Map<String, dynamic>.from(d),
      ),
    );
    // Ensure it has an empty panels list
    dashboard['panels'] ??= <Map<String, dynamic>>[];
    dashboards.add(dashboard);
    conn['dashboards'] = dashboards;
    list[connectionIndex] = conn;
    await saveConnections(list);
    return dashboards.length - 1;
  }

  /// Deletes a dashboard (and all its panels) at [dashboardIndex].
  static Future<void> deleteDashboard(
    int connectionIndex,
    int dashboardIndex,
  ) async {
    final list = loadConnections();
    if (connectionIndex < 0 || connectionIndex >= list.length) return;
    final conn = Map<String, dynamic>.from(list[connectionIndex]);
    final dashboards = List<Map<String, dynamic>>.from(
      (conn['dashboards'] as List? ?? []).map(
        (d) => Map<String, dynamic>.from(d),
      ),
    );
    if (dashboardIndex < 0 || dashboardIndex >= dashboards.length) return;
    dashboards.removeAt(dashboardIndex);
    conn['dashboards'] = dashboards;
    list[connectionIndex] = conn;
    await saveConnections(list);
  }

  // ── Panel-level operations ─────────────────────────────────

  static Future<void> addPanel(
    int connectionIndex,
    int dashboardIndex,
    Map<String, dynamic> panel,
  ) async {
    final list = loadConnections();
    if (connectionIndex < 0 || connectionIndex >= list.length) return;
    final conn = Map<String, dynamic>.from(list[connectionIndex]);
    final dashboards = List<Map<String, dynamic>>.from(
      (conn['dashboards'] as List? ?? []).map(
        (d) => Map<String, dynamic>.from(d),
      ),
    );
    if (dashboardIndex < 0 || dashboardIndex >= dashboards.length) return;
    final panels = List<Map<String, dynamic>>.from(
      (dashboards[dashboardIndex]['panels'] as List? ?? []).map(
        (p) => Map<String, dynamic>.from(p),
      ),
    );
    panels.add(panel);
    dashboards[dashboardIndex]['panels'] = panels;
    conn['dashboards'] = dashboards;
    list[connectionIndex] = conn;
    await saveConnections(list);
  }

  static Future<void> deletePanel(
    int connectionIndex,
    int dashboardIndex,
    int panelIndex,
  ) async {
    final list = loadConnections();
    if (connectionIndex < 0 || connectionIndex >= list.length) return;
    final conn = Map<String, dynamic>.from(list[connectionIndex]);
    final dashboards = List<Map<String, dynamic>>.from(
      (conn['dashboards'] as List? ?? []).map(
        (d) => Map<String, dynamic>.from(d),
      ),
    );
    if (dashboardIndex < 0 || dashboardIndex >= dashboards.length) return;
    final panels = List<Map<String, dynamic>>.from(
      (dashboards[dashboardIndex]['panels'] as List? ?? []).map(
        (p) => Map<String, dynamic>.from(p),
      ),
    );
    if (panelIndex >= 0 && panelIndex < panels.length)
      panels.removeAt(panelIndex);
    dashboards[dashboardIndex]['panels'] = panels;
    conn['dashboards'] = dashboards;
    list[connectionIndex] = conn;
    await saveConnections(list);
  }

  static Future<void> updatePanel(
    int connectionIndex,
    int dashboardIndex,
    int panelIndex,
    Map<String, dynamic> updated,
  ) async {
    final list = loadConnections();
    if (connectionIndex < 0 || connectionIndex >= list.length) return;
    final conn = Map<String, dynamic>.from(list[connectionIndex]);
    final dashboards = List<Map<String, dynamic>>.from(
      (conn['dashboards'] as List? ?? []).map(
        (d) => Map<String, dynamic>.from(d),
      ),
    );
    if (dashboardIndex < 0 || dashboardIndex >= dashboards.length) return;
    final panels = List<Map<String, dynamic>>.from(
      (dashboards[dashboardIndex]['panels'] as List? ?? []).map(
        (p) => Map<String, dynamic>.from(p),
      ),
    );
    if (panelIndex >= 0 && panelIndex < panels.length) {
      panels[panelIndex] = updated;
    }
    dashboards[dashboardIndex]['panels'] = panels;
    conn['dashboards'] = dashboards;
    list[connectionIndex] = conn;
    await saveConnections(list);
  }

  static List<Map<String, dynamic>> getPanels(
    int connectionIndex,
    int dashboardIndex,
  ) {
    final list = loadConnections();
    if (connectionIndex < 0 || connectionIndex >= list.length) return [];
    final conn = list[connectionIndex];
    final dashboards = List<dynamic>.from(conn['dashboards'] ?? []);
    if (dashboardIndex < 0 || dashboardIndex >= dashboards.length) return [];
    final panels = List<dynamic>.from(
      dashboards[dashboardIndex]['panels'] ?? [],
    );
    return panels
        .map<Map<String, dynamic>>((p) => Map<String, dynamic>.from(p))
        .toList();
  }
}
