import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class DashboardProvider extends ChangeNotifier {
  final int connectionIndex;
  int currentTabIndex = 0;
  List<Map<String, dynamic>> _dashboards = [];
  List<Map<String, dynamic>> _panels = [];

  DashboardProvider({required this.connectionIndex}) {
    loadData();
  }

  List<Map<String, dynamic>> get dashboards => _dashboards;
  List<Map<String, dynamic>> get panels => _panels;

  void loadData() {
    _dashboards = StorageService.getDashboards(connectionIndex);
    if (_dashboards.isNotEmpty) {
      _panels = StorageService.getPanels(connectionIndex, currentTabIndex);
    } else {
      _panels = [];
    }
    notifyListeners(); // This is the "Magic" that updates the UI
  }

  void setTab(int index) {
    currentTabIndex = index;
    loadData();
  }

  Future<void> addPanel(Map<String, dynamic> panelData) async {
    await StorageService.addPanel(connectionIndex, currentTabIndex, panelData);
    loadData(); // Reloads list and calls notifyListeners()
  }

  Future<void> deletePanel(int panelIndex) async {
    await StorageService.deletePanel(connectionIndex, currentTabIndex, panelIndex);
    loadData();
  }

  Future<void> addDashboard(Map<String, dynamic> data) async {
    await StorageService.addDashboard(connectionIndex, data);
    loadData();
  }
}