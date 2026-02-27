// lib/screens/widgets/icon_picker_sheet.dart

import 'package:flutter/material.dart';

// ── Serialization ─────────────────────────────────────────────
// We store icons by their codePoint hex string (e.g. "0xe318").
// iconFromString does a LOOKUP in _kAllIcons map — never constructs
// IconData dynamically — so tree-shaking works in release builds.

String iconToString(IconData icon) =>
    '0x${icon.codePoint.toRadixString(16)}';

IconData iconFromString(String? s) {
  if (s == null || s.isEmpty) return Icons.dashboard_outlined;
  // Try exact hex lookup first (e.g. "0xe318" or "e318")
  final normalized = s.startsWith('0x') ? s : '0x$s';
  return _kAllIcons[normalized] ?? Icons.dashboard_outlined;
}

// ── Icon catalogue ────────────────────────────────────────────

class _IconEntry {
  final String label;
  final IconData icon;
  const _IconEntry(this.label, this.icon);
}

class _IconCategory {
  final String name;
  final List<_IconEntry> icons;
  const _IconCategory(this.name, this.icons);
}

const List<_IconCategory> _kIconCategories = [
  _IconCategory('Dashboard', [
    _IconEntry('Dashboard', Icons.dashboard_outlined),
    _IconEntry('Home', Icons.home_outlined),
    _IconEntry('Grid', Icons.grid_view_outlined),
    _IconEntry('Layers', Icons.layers_outlined),
    _IconEntry('View list', Icons.view_list_outlined),
    _IconEntry('Analytics', Icons.analytics_outlined),
    _IconEntry('Bar chart', Icons.bar_chart),
    _IconEntry('Show chart', Icons.show_chart),
    _IconEntry('Pie chart', Icons.pie_chart_outline),
    _IconEntry('Speed', Icons.speed),
    _IconEntry('Monitor', Icons.monitor_outlined),
    _IconEntry('Widgets', Icons.widgets_outlined),
  ]),
  _IconCategory('Smart Home / IoT', [
    _IconEntry('Fan', Icons.air),
    _IconEntry('Light', Icons.light_outlined),
    _IconEntry('Lightbulb', Icons.lightbulb_outline),
    _IconEntry('Power', Icons.power_settings_new),
    _IconEntry('Outlet', Icons.outlet_outlined),
    _IconEntry('Thermostat', Icons.thermostat),
    _IconEntry('Water drop', Icons.water_drop_outlined),
    _IconEntry('Waves', Icons.waves),
    _IconEntry('Heat', Icons.local_fire_department_outlined),
    _IconEntry('AC unit', Icons.ac_unit),
    _IconEntry('Sensor', Icons.sensors),
    _IconEntry('Wifi', Icons.wifi),
    _IconEntry('Bluetooth', Icons.bluetooth),
    _IconEntry('Router', Icons.router_outlined),
    _IconEntry('Device hub', Icons.device_hub),
    _IconEntry('Door', Icons.door_front_door_outlined),
    _IconEntry('Window', Icons.window_outlined),
    _IconEntry('Garage', Icons.garage_outlined),
    _IconEntry('Camera', Icons.camera_alt_outlined),
    _IconEntry('Lock', Icons.lock_outline),
    _IconEntry('Unlock', Icons.lock_open_outlined),
    _IconEntry('Security', Icons.security_outlined),
    _IconEntry('Battery', Icons.battery_charging_full),
    _IconEntry('Solar', Icons.solar_power_outlined),
    _IconEntry('Electric', Icons.electric_bolt),
    _IconEntry('Gas', Icons.gas_meter_outlined),
    _IconEntry('Water meter', Icons.water_damage_outlined),
    _IconEntry('Alarm', Icons.alarm),
    _IconEntry('Notification', Icons.notifications_outlined),
    _IconEntry('Bell', Icons.doorbell_outlined),
  ]),
  _IconCategory('Controls', [
    _IconEntry('Toggle on', Icons.toggle_on_outlined),
    _IconEntry('Toggle off', Icons.toggle_off_outlined),
    _IconEntry('Slider', Icons.tune),
    _IconEntry('Play', Icons.play_arrow),
    _IconEntry('Pause', Icons.pause),
    _IconEntry('Stop', Icons.stop),
    _IconEntry('Forward', Icons.fast_forward),
    _IconEntry('Rewind', Icons.fast_rewind),
    _IconEntry('Up', Icons.keyboard_arrow_up),
    _IconEntry('Down', Icons.keyboard_arrow_down),
    _IconEntry('Left', Icons.keyboard_arrow_left),
    _IconEntry('Right', Icons.keyboard_arrow_right),
    _IconEntry('Refresh', Icons.refresh),
    _IconEntry('Sync', Icons.sync),
    _IconEntry('Send', Icons.send_outlined),
    _IconEntry('Check', Icons.check_circle_outline),
    _IconEntry('Close', Icons.cancel_outlined),
    _IconEntry('Add', Icons.add_circle_outline),
    _IconEntry('Remove', Icons.remove_circle_outline),
    _IconEntry('Settings', Icons.settings_outlined),
    _IconEntry('Tune', Icons.tune_outlined),
    _IconEntry('Build', Icons.build_outlined),
  ]),
  _IconCategory('Energy & Environment', [
    _IconEntry('Temperature', Icons.device_thermostat),
    _IconEntry('Humidity', Icons.water_outlined),
    _IconEntry('Pressure', Icons.compress),
    _IconEntry('Wind', Icons.air_outlined),
    _IconEntry('Cloud', Icons.cloud_outlined),
    _IconEntry('Rain', Icons.grain),
    _IconEntry('Storm', Icons.thunderstorm_outlined),
    _IconEntry('Sun', Icons.wb_sunny_outlined),
    _IconEntry('Moon', Icons.nightlight_outlined),
    _IconEntry('Energy', Icons.energy_savings_leaf_outlined),
    _IconEntry('Flash', Icons.bolt),
    _IconEntry('Eco', Icons.eco_outlined),
  ]),
  _IconCategory('Vehicles & Transport', [
    _IconEntry('Car', Icons.directions_car_outlined),
    _IconEntry('EV car', Icons.electric_car_outlined),
    _IconEntry('Motorbike', Icons.two_wheeler),
    _IconEntry('Truck', Icons.local_shipping_outlined),
    _IconEntry('Boat', Icons.directions_boat_outlined),
    _IconEntry('Flight', Icons.flight_outlined),
    _IconEntry('Train', Icons.train_outlined),
    _IconEntry('Bike', Icons.pedal_bike_outlined),
    _IconEntry('Speed gauge', Icons.speed),
    _IconEntry('GPS', Icons.gps_fixed),
    _IconEntry('Map', Icons.map_outlined),
    _IconEntry('Location', Icons.location_on_outlined),
  ]),
  _IconCategory('Industry & Tools', [
    _IconEntry('Factory', Icons.factory_outlined),
    _IconEntry('Precision', Icons.precision_manufacturing_outlined),
    _IconEntry('Hardware', Icons.hardware_outlined),
    _IconEntry('Construction', Icons.construction_outlined),
    _IconEntry('Handyman', Icons.handyman_outlined),
    _IconEntry('Cable', Icons.cable),
    _IconEntry('Memory', Icons.memory),
    _IconEntry('CPU', Icons.developer_board),
    _IconEntry('Storage', Icons.storage),
    _IconEntry('Server', Icons.dns_outlined),
    _IconEntry('Terminal', Icons.terminal),
    _IconEntry('Code', Icons.code),
    _IconEntry('Api', Icons.api),
    _IconEntry('Cloud upload', Icons.cloud_upload_outlined),
    _IconEntry('Cloud download', Icons.cloud_download_outlined),
    _IconEntry('Database', Icons.dataset_outlined),
  ]),
  _IconCategory('People & Places', [
    _IconEntry('Person', Icons.person_outline),
    _IconEntry('Group', Icons.group_outlined),
    _IconEntry('Office', Icons.business_outlined),
    _IconEntry('Store', Icons.store_outlined),
    _IconEntry('Hospital', Icons.local_hospital_outlined),
    _IconEntry('School', Icons.school_outlined),
    _IconEntry('Park', Icons.park_outlined),
    _IconEntry('Restaurant', Icons.restaurant_outlined),
    _IconEntry('Coffee', Icons.coffee_outlined),
    _IconEntry('Hotel', Icons.hotel_outlined),
    _IconEntry('Apartment', Icons.apartment_outlined),
    _IconEntry('Landscape', Icons.landscape_outlined),
  ]),
];

// ── Flat lookup map: "0x{hex}" → IconData ─────────────────────
// Built from _kIconCategories so it's always in sync.
// iconFromString uses this instead of constructing IconData at runtime.
final Map<String, IconData> _kAllIcons = {
  for (final cat in _kIconCategories)
    for (final e in cat.icons)
      '0x${e.icon.codePoint.toRadixString(16)}': e.icon,
};

// ── Public API ────────────────────────────────────────────────

Future<IconData?> showIconPicker(BuildContext context,
    {IconData? current}) async {
  return showModalBottomSheet<IconData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _IconPickerSheet(current: current),
  );
}

// ── Sheet widget ──────────────────────────────────────────────

class _IconPickerSheet extends StatefulWidget {
  final IconData? current;
  const _IconPickerSheet({this.current});

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_IconEntry> get _filtered {
    if (_search.isEmpty) return [];
    final q = _search.toLowerCase();
    return _kIconCategories
        .expand((c) => c.icons)
        .where((e) => e.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenH * 0.82,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Choose icon',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search icons…',
                prefixIcon:
                const Icon(Icons.search, color: Colors.black38),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black38),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _search.isNotEmpty
                ? _buildGrid(_filtered)
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: _kIconCategories.length,
              itemBuilder: (_, i) {
                final cat = _kIconCategories[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(cat.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                              letterSpacing: 0.5)),
                    ),
                    _buildGrid(cat.icons),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_IconEntry> entries) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.9,
      ),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final entry = entries[i];
        final isSelected =
            widget.current?.codePoint == entry.icon.codePoint;
        return GestureDetector(
          onTap: () => Navigator.pop(context, entry.icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1E88E5).withOpacity(0.12)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1E88E5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(entry.icon,
                    size: 26,
                    color: isSelected
                        ? const Color(0xFF1E88E5)
                        : Colors.black54),
                const SizedBox(height: 4),
                Text(
                  entry.label,
                  style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? const Color(0xFF1E88E5)
                          : Colors.black45),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}