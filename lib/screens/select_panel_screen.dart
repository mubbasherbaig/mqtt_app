import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:mqtt_app/screens/panels/button_panel.dart';
import 'package:mqtt_app/screens/panels/color_picker_panel.dart';
import 'package:mqtt_app/screens/panels/combo_box_panel.dart';
import 'package:mqtt_app/screens/panels/gauge_panel.dart';
import 'package:mqtt_app/screens/panels/led_indicator_panel.dart';
import 'package:mqtt_app/screens/panels/multi_state_indicator_panel.dart';
import 'package:mqtt_app/screens/panels/node_status_panel.dart';
import 'package:mqtt_app/screens/panels/progress_panel.dart';
import 'package:mqtt_app/screens/panels/radio_buttons_panel.dart';
import 'package:mqtt_app/screens/panels/slider_panel.dart';
import 'package:mqtt_app/screens/panels/switch_panel.dart';
import 'package:mqtt_app/screens/panels/text_input_panel.dart';
import 'package:mqtt_app/screens/panels/text_output_panel.dart';
import 'package:mqtt_app/screens/panels/bar_graph_panel.dart';
import 'package:mqtt_app/screens/panels/barcode_scannner_panel.dart';
import 'package:mqtt_app/screens/panels/chart_panel.dart';
import 'package:mqtt_app/screens/panels/date_time_picker.dart';
import 'package:mqtt_app/screens/panels/image_panel.dart';
import 'package:mqtt_app/screens/panels/layout_decorator_panel.dart';
import 'package:mqtt_app/screens/panels/line_graph_panel.dart';
import 'package:mqtt_app/screens/panels/uri_launcher_panel.dart';

class SelectPanelScreen extends StatelessWidget {
  const SelectPanelScreen({super.key});

  static final List<Map<String, dynamic>> _panelTypes = [
    {'label': 'Button',                'icon': _PanelIcons.button},
    {'label': 'Switch',                'icon': _PanelIcons.switchToggle},
    {'label': 'Slider',                'icon': _PanelIcons.slider},
    {'label': 'Text Input',            'icon': _PanelIcons.textInput},
    {'label': 'Text Output',           'icon': _PanelIcons.textOutput},
    {'label': 'Node Status',           'icon': _PanelIcons.nodeStatus},
    {'label': 'Combo Box',             'icon': _PanelIcons.comboBox},
    {'label': 'Radio Buttons',         'icon': _PanelIcons.radioButtons},
    {'label': 'LED Indicator',         'icon': _PanelIcons.ledIndicator},
    {'label': 'Multi-State Indicator', 'icon': _PanelIcons.multiState},
    {'label': 'Progress',              'icon': _PanelIcons.progress},
    {'label': 'Gauge',                 'icon': _PanelIcons.gauge},
    {'label': 'Color Picker',          'icon': _PanelIcons.colorPicker},
    {'label': 'Date & Time Picker',    'icon': _PanelIcons.dateTime},
    {'label': 'Line Graph',            'icon': _PanelIcons.lineGraph},
    {'label': 'Bar Graph',             'icon': _PanelIcons.barGraph},
    {'label': 'Chart',                 'icon': _PanelIcons.chart},
    {'label': 'Image',                 'icon': _PanelIcons.image},
    {'label': 'Barcode Scanner',       'icon': _PanelIcons.barcode},
    {'label': 'URI Launcher',          'icon': _PanelIcons.uriLauncher},
    {'label': 'Layout Decorator',      'icon': _PanelIcons.layoutDecorator},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select panel type to add',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            // List
            Expanded(
              child: ListView.separated(
                itemCount: _panelTypes.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                itemBuilder: (context, index) {
                  final panel = _panelTypes[index];
                  return InkWell(
                    onTap: () async {
                      final label = panel['label'] as String;
                      if (label == 'Button') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddButtonPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Switch') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddSwitchPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Slider') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddSliderPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Text Input') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddTextInputPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Text Output') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddTextOutputPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Node Status') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddNodeStatusPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Combo Box') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddComboBoxPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Radio Buttons') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddRadioButtonsPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'LED Indicator') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddLedIndicatorPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Multi-State Indicator') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddMultiStateIndicatorPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Progress') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddProgressPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Gauge') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddGaugePanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Color Picker') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddColorPickerPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Date & Time Picker') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddDateTimePickerPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Line Graph') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddLineGraphPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Bar Graph') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddBarGraphPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Chart') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddChartPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Image') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddImagePanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Barcode Scanner') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddBarcodeScannerPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'URI Launcher') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddUriLauncherPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else if (label == 'Layout Decorator') {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddLayoutDecoratorPanelScreen()),
                        );
                        if (result != null && context.mounted) Navigator.pop(context, result);
                      } else {
                        Navigator.pop(context, {'type': label});
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // Custom icon painter
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CustomPaint(
                              painter: panel['icon'] as CustomPainter,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              panel['label'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Blue ? circle
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E88E5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.question_mark,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Custom Icon Painters ───────────────

class _PanelIcons {
  static final button         = _ButtonIconPainter();
  static final switchToggle   = _SwitchIconPainter();
  static final slider         = _SliderIconPainter();
  static final textInput      = _TextInputIconPainter();
  static final textOutput     = _TextOutputIconPainter();
  static final nodeStatus     = _NodeStatusIconPainter();
  static final comboBox       = _ComboBoxIconPainter();
  static final radioButtons   = _RadioButtonIconPainter();
  static final ledIndicator   = _LedIndicatorIconPainter();
  static final multiState     = _MultiStateIconPainter();
  static final progress       = _ProgressIconPainter();
  static final gauge          = _GaugeIconPainter();
  static final colorPicker    = _ColorPickerIconPainter();
  static final dateTime       = _DateTimeIconPainter();
  static final lineGraph      = _LineGraphIconPainter();
  static final barGraph       = _BarGraphIconPainter();
  static final chart          = _ChartIconPainter();
  static final image          = _ImageIconPainter();
  static final barcode        = _BarcodeIconPainter();
  static final uriLauncher    = _UriLauncherIconPainter();
  static final layoutDecorator = _LayoutDecoratorIconPainter();
}

Paint get _iconPaint => Paint()
  ..color = Colors.black87
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.2
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint get _iconFill => Paint()
  ..color = Colors.black87
  ..style = PaintingStyle.fill;

// Button: rectangle with rounded corners
class _ButtonIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 8, s.width - 4, s.height - 16), const Radius.circular(4)),
      _iconPaint,
    );
  }
  @override bool shouldRepaint(_) => false;
}

// Switch: pill with circle inside (toggled on)
class _SwitchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconFill;
    // pill background (filled dark)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, s.height * 0.25, s.width, s.height * 0.5), Radius.circular(s.height * 0.25)),
      p,
    );
    // white circle on right side
    canvas.drawCircle(
      Offset(s.width * 0.72, s.height * 0.5),
      s.height * 0.22,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
  }
  @override bool shouldRepaint(_) => false;
}

// Slider: line with circle knob
class _SliderIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2.5;
    canvas.drawLine(Offset(2, s.height * 0.5), Offset(s.width - 2, s.height * 0.5), p);
    canvas.drawCircle(Offset(s.width * 0.38, s.height * 0.5), 7, _iconFill);
  }
  @override bool shouldRepaint(_) => false;
}

// Text Input: chat bubble with lines
class _TextInputIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconFill;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s.width, s.height * 0.78), const Radius.circular(4)))
      ..moveTo(s.width * 0.2, s.height * 0.78)
      ..lineTo(s.width * 0.1, s.height)
      ..lineTo(s.width * 0.4, s.height * 0.78)
      ..close();
    canvas.drawPath(path, p);
    // white lines inside
    final lp = Paint()..color = Colors.white..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width*0.18, s.height*0.3), Offset(s.width*0.82, s.height*0.3), lp);
    canvas.drawLine(Offset(s.width*0.18, s.height*0.52), Offset(s.width*0.65, s.height*0.52), lp);
  }
  @override bool shouldRepaint(_) => false;
}

// Text Output: two horizontal lines
class _TextOutputIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2.8;
    canvas.drawLine(Offset(0, s.height * 0.38), Offset(s.width, s.height * 0.38), p);
    canvas.drawLine(Offset(0, s.height * 0.62), Offset(s.width * 0.7, s.height * 0.62), p);
  }
  @override bool shouldRepaint(_) => false;
}

// Node Status: wifi-like signal with diagonal lines
class _NodeStatusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2.5;
    // diagonal cross lines
    canvas.drawLine(Offset(0, s.height * 0.2), Offset(s.width * 0.5, s.height * 0.8), p);
    canvas.drawLine(Offset(s.width * 0.15, 0), Offset(s.width * 0.15, s.height), p);
    // wifi arcs on right
    final center = Offset(s.width * 0.72, s.height * 0.78);
    final ap = _iconPaint..strokeWidth = 2;
    for (final r in [0.28, 0.18, 0.09]) {
      canvas.drawArc(
        Rect.fromCenter(center: center, width: s.width * r * 2, height: s.width * r * 2),
        3.14 + 0.4, 2.3, false, ap,
      );
    }
    canvas.drawCircle(center, 2.5, _iconFill);
  }
  @override bool shouldRepaint(_) => false;
}

// Combo Box: list with checkmark
class _ComboBoxIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2.2;
    // 3 lines
    for (int i = 0; i < 3; i++) {
      final y = s.height * (0.25 + i * 0.25);
      canvas.drawLine(Offset(s.width * 0.28, y), Offset(s.width, y), p);
    }
    // checkmark on left
    final cp = _iconPaint..strokeWidth = 2.5;
    canvas.drawLine(Offset(0, s.height * 0.52), Offset(s.width * 0.12, s.height * 0.65), cp);
    canvas.drawLine(Offset(s.width * 0.12, s.height * 0.65), Offset(s.width * 0.24, s.height * 0.38), cp);
  }
  @override bool shouldRepaint(_) => false;
}

// Radio Buttons: outer circle with inner filled circle
class _RadioButtonIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    canvas.drawCircle(center, s.width * 0.46, _iconPaint..strokeWidth = 2.5);
    canvas.drawCircle(center, s.width * 0.28, _iconFill);
  }
  @override bool shouldRepaint(_) => false;
}

// LED Indicator: bell/notification shape
class _LedIndicatorIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconFill;
    // bell body
    final path = Path()
      ..moveTo(s.width * 0.5, 0)
      ..lineTo(s.width * 0.5, s.height * 0.08)
      ..arcTo(Rect.fromLTWH(s.width * 0.08, s.height * 0.08, s.width * 0.84, s.height * 0.7), 3.14, -3.14, false)
      ..lineTo(s.width, s.height * 0.78)
      ..lineTo(0, s.height * 0.78)
      ..close();
    canvas.drawPath(path, p);
    // clapper
    canvas.drawArc(
      Rect.fromLTWH(s.width * 0.3, s.height * 0.78, s.width * 0.4, s.height * 0.22),
      0, 3.14, false,
      _iconFill,
    );
  }
  @override bool shouldRepaint(_) => false;
}

// Multi-State Indicator: lines with play arrow
class _MultiStateIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2.2;
    for (int i = 0; i < 3; i++) {
      final y = s.height * (0.25 + i * 0.25);
      canvas.drawLine(Offset(s.width * 0.35, y), Offset(s.width, y), p);
    }
    // play triangle
    final tri = Path()
      ..moveTo(0, s.height * 0.2)
      ..lineTo(s.width * 0.28, s.height * 0.5)
      ..lineTo(0, s.height * 0.8)
      ..close();
    canvas.drawPath(tri, _iconFill);
  }
  @override bool shouldRepaint(_) => false;
}

// Progress: battery/progress bar shape
class _ProgressIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    // outer rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, s.height * 0.2, s.width * 0.88, s.height * 0.6), const Radius.circular(2)),
      _iconPaint..strokeWidth = 2.2,
    );
    // battery tip
    canvas.drawRect(Rect.fromLTWH(s.width * 0.9, s.height * 0.38, s.width * 0.1, s.height * 0.24), _iconFill);
    // fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(3, s.height * 0.28, s.width * 0.55, s.height * 0.44), const Radius.circular(1)),
      _iconFill,
    );
  }
  @override bool shouldRepaint(_) => false;
}

// Gauge: half circle with needle
class _GaugeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2.5;
    // arc ticks
    final center = Offset(s.width / 2, s.height * 0.72);
    canvas.drawArc(Rect.fromCenter(center: center, width: s.width * 0.9, height: s.width * 0.9), 3.14, -3.14, false, p);
    // tick marks
    for (int i = 0; i <= 4; i++) {
      final angle = 3.14 + (i / 4) * 3.14;
      final r1 = s.width * 0.42;
      final r2 = s.width * 0.35;
      canvas.drawLine(
        Offset(center.dx + r1 * math.cos(angle), center.dy + r1 * math.sin(angle)),
        Offset(center.dx + r2 * math.cos(angle), center.dy + r2 * math.sin(angle)),
        _iconPaint..strokeWidth = 1.5,
      );
    }
    // needle
    const needleAngle = 3.14 + 0.8;
    canvas.drawLine(
      center,
      Offset(center.dx + s.width * 0.38 * math.cos(needleAngle), center.dy + s.width * 0.38 * math.sin(needleAngle)),
      _iconPaint..strokeWidth = 2,
    );
  }
  @override bool shouldRepaint(_) => false;
}

// Color Picker: palette
class _ColorPickerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2;
    final center = Offset(s.width / 2, s.height / 2);
    canvas.drawCircle(center, s.width * 0.46, p);
    canvas.drawCircle(Offset(s.width * 0.62, s.height * 0.72), s.width * 0.14, _iconFill);
    // color dots
    final dots = [
      Offset(s.width * 0.3, s.height * 0.28),
      Offset(s.width * 0.55, s.height * 0.22),
      Offset(s.width * 0.75, s.height * 0.38),
      Offset(s.width * 0.25, s.height * 0.55),
    ];
    for (final d in dots) {
      canvas.drawCircle(d, 3.5, _iconFill);
    }
    // thumb hole
    canvas.drawCircle(Offset(s.width * 0.38, s.height * 0.72), s.width * 0.12,
        Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(s.width * 0.38, s.height * 0.72), s.width * 0.12, p);
  }
  @override bool shouldRepaint(_) => false;
}

// Date & Time Picker: calendar
class _DateTimeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2;
    // calendar body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1, s.height * 0.15, s.width - 2, s.height * 0.8), const Radius.circular(3)),
      p,
    );
    // top bar fill
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(1, s.height * 0.15, s.width - 2, s.height * 0.28),
        topLeft: const Radius.circular(3), topRight: const Radius.circular(3),
      ),
      _iconFill,
    );
    // grid dots
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 3; c++) {
        canvas.drawCircle(
          Offset(s.width * (0.22 + c * 0.28), s.height * (0.6 + r * 0.22)),
          2.5, _iconFill,
        );
      }
    }
    // page curl bottom right
    final curl = Path()
      ..moveTo(s.width * 0.7, s.height * 0.95)
      ..lineTo(s.width - 1, s.height * 0.7)
      ..lineTo(s.width - 1, s.height * 0.95)
      ..close();
    canvas.drawPath(curl, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawPath(curl, p);
  }
  @override bool shouldRepaint(_) => false;
}

// Line Graph: upward trending line
class _LineGraphIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2.2;
    // axes
    canvas.drawLine(Offset(2, 2), Offset(2, s.height - 2), p);
    canvas.drawLine(Offset(2, s.height - 2), Offset(s.width - 2, s.height - 2), p);
    // trend line
    final lp = _iconPaint..strokeWidth = 2.5;
    final path = Path()
      ..moveTo(4, s.height * 0.75)
      ..lineTo(s.width * 0.3, s.height * 0.5)
      ..lineTo(s.width * 0.55, s.height * 0.65)
      ..lineTo(s.width * 0.8, s.height * 0.2);
    canvas.drawPath(path, lp);
  }
  @override bool shouldRepaint(_) => false;
}

// Bar Graph
class _BarGraphIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconFill;
    final heights = [0.4, 0.65, 0.5, 0.8, 0.3];
    final barW = s.width / (heights.length * 1.6);
    for (int i = 0; i < heights.length; i++) {
      final x = i * (barW * 1.6) + barW * 0.3;
      final h = s.height * heights[i];
      canvas.drawRect(Rect.fromLTWH(x, s.height - h, barW, h), p);
    }
    // baseline
    canvas.drawLine(Offset(0, s.height - 1), Offset(s.width, s.height - 1), _iconPaint..strokeWidth = 1.5);
  }
  @override bool shouldRepaint(_) => false;
}

// Chart: pie chart
class _ChartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final r = s.width * 0.46;
    final colors = [Colors.black87, Colors.black54, Colors.black26];
    final sweeps = [2.2, 2.5, 1.58];
    double start = -1.57;
    for (int i = 0; i < sweeps.length; i++) {
      canvas.drawArc(
        Rect.fromCenter(center: center, width: r * 2, height: r * 2),
        start, sweeps[i], true,
        Paint()..color = colors[i]..style = PaintingStyle.fill,
      );
      start += sweeps[i];
    }
  }
  @override bool shouldRepaint(_) => false;
}

// Image: photo frame with mountain
class _ImageIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, s.width - 2, s.height - 2), const Radius.circular(3)),
      p,
    );
    // mountain
    final mp = _iconFill;
    canvas.drawPath(
      Path()
        ..moveTo(s.width * 0.1, s.height * 0.82)
        ..lineTo(s.width * 0.38, s.height * 0.38)
        ..lineTo(s.width * 0.62, s.height * 0.62)
        ..lineTo(s.width * 0.75, s.height * 0.48)
        ..lineTo(s.width * 0.9, s.height * 0.82)
        ..close(),
      mp,
    );
    // sun
    canvas.drawCircle(Offset(s.width * 0.22, s.height * 0.28), 5, _iconFill);
  }
  @override bool shouldRepaint(_) => false;
}

// Barcode Scanner
class _BarcodeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconFill;
    // vertical bars
    final widths = [2.0, 3.5, 2.0, 4.5, 2.0, 3.0, 2.5, 4.0, 2.0, 3.5, 2.0];
    double x = 2;
    bool filled = true;
    for (final w in widths) {
      if (filled) {
        canvas.drawRect(Rect.fromLTWH(x, s.height * 0.1, w, s.height * 0.8), p);
      }
      x += w + 1.5;
      filled = !filled;
    }
  }
  @override bool shouldRepaint(_) => false;
}

// URI Launcher: external link box
class _UriLauncherIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2.2;
    // box with open top-right
    canvas.drawPath(
      Path()
        ..moveTo(s.width * 0.5, 2)
        ..lineTo(s.width - 2, 2)
        ..lineTo(s.width - 2, s.height * 0.5),
      p,
    );
    // arrow
    canvas.drawLine(Offset(s.width - 2, 2), Offset(s.width * 0.35, s.height * 0.65), p);
    // bottom box
    canvas.drawPath(
      Path()
        ..moveTo(s.width * 0.45, s.height * 0.18)
        ..lineTo(s.width * 0.12, s.height * 0.18)
        ..lineTo(s.width * 0.12, s.height - 2)
        ..lineTo(s.width - 2, s.height - 2)
        ..lineTo(s.width - 2, s.height * 0.55),
      p,
    );
  }
  @override bool shouldRepaint(_) => false;
}

// Layout Decorator: two panels side by side
class _LayoutDecoratorIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = _iconPaint..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, s.width - 2, s.height - 2), const Radius.circular(2)),
      p,
    );
    // inner dividers
    canvas.drawLine(Offset(s.width * 0.5, 1), Offset(s.width * 0.5, s.height - 1), p);
    canvas.drawLine(Offset(1, s.height * 0.42), Offset(s.width - 1, s.height * 0.42), p);
  }
  @override bool shouldRepaint(_) => false;
}