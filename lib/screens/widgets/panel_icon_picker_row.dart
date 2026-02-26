// lib/screens/widgets/panel_icon_picker_row.dart
//
// A ready-made form row for panel screens that lets the user pick an icon.
// Drop it anywhere in a panel's ListView form, just like _fieldRow or _checkRow.
//
// Example usage inside a panel screen's State class:
//
//   IconData _panelIcon = Icons.widgets_outlined;
//
//   // In the build / ListView, add:
//   PanelIconPickerRow(
//     selectedIcon: _panelIcon,
//     onChanged: (icon) => setState(() => _panelIcon = icon),
//   ),
//   _divider(),     // same divider already used throughout panel forms
//
//   // When building the result map, add:
//   'icon': iconToString(_panelIcon),

import 'package:flutter/material.dart';
import 'icon_picker_sheet.dart';

class PanelIconPickerRow extends StatelessWidget {
  final IconData selectedIcon;
  final ValueChanged<IconData> onChanged;
  /// Label shown on the left — defaults to 'Panel icon'
  final String? label;

  const PanelIconPickerRow({
    super.key,
    required this.selectedIcon,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label ?? 'Panel icon',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          // Preview + tap to change
          GestureDetector(
            onTap: () async {
              final icon = await showIconPicker(
                context,
                current: selectedIcon,
              );
              if (icon != null) onChanged(icon);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF1E88E5).withOpacity(0.35),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(selectedIcon,
                        size: 24, color: const Color(0xFF1E88E5)),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E88E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit,
                          size: 8, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}