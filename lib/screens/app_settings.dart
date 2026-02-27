// lib/screens/app_settings.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AppSettings extends ChangeNotifier {
  static const _keyLanguage           = 'setting_language';
  static const _keyDarkTheme          = 'setting_dark_theme';
  static const _keyRunInBackground    = 'setting_run_in_background';
  static const _keyDisableBattery     = 'setting_disable_battery';
  static const _keyKeepScreenOn       = 'setting_keep_screen_on';
  static const _keyDefaultConnection  = 'setting_default_connection';
  static const _keyOrientation        = 'setting_orientation';
  static const _keyDashboardPlacement = 'setting_dashboard_placement';

  SharedPreferences? _prefs;

  // ── State ──────────────────────────────────────────────────
  String _languageCode        = 'en';
  bool   _darkTheme           = false;
  bool   _runInBackground     = false;
  bool   _disableBatteryOpt   = false;
  bool   _keepScreenOn        = false;
  String _defaultConnection   = 'none';
  String _orientation         = 'Portrait';
  String _dashboardPlacement  = 'Bottom Bar';

  // ── Getters ────────────────────────────────────────────────
  String get languageCode       => _languageCode;
  bool   get darkTheme          => _darkTheme;
  bool   get runInBackground    => _runInBackground;
  bool   get disableBatteryOpt  => _disableBatteryOpt;
  bool   get keepScreenOn       => _keepScreenOn;
  String get defaultConnection  => _defaultConnection;
  String get orientation        => _orientation;
  String get dashboardPlacement => _dashboardPlacement;

  // ── Init — load + apply all settings at startup ────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _languageCode       = _prefs!.getString(_keyLanguage)           ?? 'en';
    _darkTheme          = _prefs!.getBool(_keyDarkTheme)            ?? false;
    _runInBackground    = _prefs!.getBool(_keyRunInBackground)      ?? false;
    _disableBatteryOpt  = _prefs!.getBool(_keyDisableBattery)       ?? false;
    _keepScreenOn       = _prefs!.getBool(_keyKeepScreenOn)         ?? false;
    _defaultConnection  = _prefs!.getString(_keyDefaultConnection)  ?? 'none';
    _orientation        = _prefs!.getString(_keyOrientation)        ?? 'Portrait';
    _dashboardPlacement = _prefs!.getString(_keyDashboardPlacement) ?? 'Bottom Bar';

    // Apply hardware/system settings immediately on startup
    await _applyOrientation(_orientation);
    await _applyWakelock(_keepScreenOn);

    notifyListeners();
  }

  // ── Language ───────────────────────────────────────────────
  // Instantly re-renders all UI text via AppLocalizations
  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await _prefs?.setString(_keyLanguage, code);
    notifyListeners();
  }

  // ── Dark theme ─────────────────────────────────────────────
  // MaterialApp in main.dart reads settings.darkTheme via context.watch
  // and switches ThemeMode automatically — nothing extra needed here
  Future<void> setDarkTheme(bool v) async {
    _darkTheme = v;
    await _prefs?.setBool(_keyDarkTheme, v);
    notifyListeners();
  }

  // ── Orientation ────────────────────────────────────────────
  // Locks the device to portrait or landscape immediately
  Future<void> setOrientation(String v) async {
    _orientation = v;
    await _prefs?.setString(_keyOrientation, v);
    await _applyOrientation(v);
    notifyListeners();
  }

  Future<void> _applyOrientation(String v) async {
    if (v == 'Landscape') {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  // ── Keep screen on ─────────────────────────────────────────
  // Prevents the screen from dimming/sleeping while the app is open
  Future<void> setKeepScreenOn(bool v) async {
    _keepScreenOn = v;
    await _prefs?.setBool(_keyKeepScreenOn, v);
    await _applyWakelock(v);
    notifyListeners();
  }

  Future<void> _applyWakelock(bool enable) async {
    try {
      await WakelockPlus.toggle(enable: enable);
    } catch (_) {
      // Platform doesn't support wakelock — silently ignore
    }
  }

  // ── Run in background ──────────────────────────────────────
  // Stores the preference. The MultiMqttService / connections_screen
  // reads this flag to decide whether to start the foreground service.
  Future<void> setRunInBackground(bool v) async {
    _runInBackground = v;
    await _prefs?.setBool(_keyRunInBackground, v);
    notifyListeners();
  }

  // ── Disable battery optimization ──────────────────────────
  // On Android, opens the system battery optimization settings so the
  // user can manually whitelist the app. The toggle just tracks whether
  // they've been directed there; we can't programmatically disable it.
  Future<void> setDisableBatteryOpt(bool v) async {
    _disableBatteryOpt = v;
    await _prefs?.setBool(_keyDisableBattery, v);
    notifyListeners();
    // Opening settings is handled in the screen via url_launcher
    // (see AppSettingsScreen) — we don't do it here to avoid
    // opening it on every hot-restart during development.
  }

  // ── Default connection ─────────────────────────────────────
  // The name of the connection to auto-open on app launch.
  // 'none' means no auto-connect. ConnectionsScreen reads this in initState.
  Future<void> setDefaultConnection(String v) async {
    _defaultConnection = v;
    await _prefs?.setString(_keyDefaultConnection, v);
    notifyListeners();
  }

  // ── Dashboard placement ────────────────────────────────────
  // 'Bottom Bar' or 'Side Bar' — DashboardScreen reads this to decide
  // which tab layout to use.
  Future<void> setDashboardPlacement(String v) async {
    _dashboardPlacement = v;
    await _prefs?.setString(_keyDashboardPlacement, v);
    notifyListeners();
  }
}