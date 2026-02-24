import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const _keyLanguage              = 'setting_language';
  static const _keyDarkTheme             = 'setting_dark_theme';
  static const _keyRunInBackground       = 'setting_run_in_background';
  static const _keyStartOnBoot           = 'setting_start_on_boot';
  static const _keyDisableBattery        = 'setting_disable_battery';
  static const _keyKeepScreenOn          = 'setting_keep_screen_on';
  static const _keyDefaultConnection     = 'setting_default_connection';
  static const _keyOrientation           = 'setting_orientation';
  static const _keyDashboardPlacement    = 'setting_dashboard_placement';

  SharedPreferences? _prefs;

  // ── State ──────────────────────────────────────────────────
  String _languageCode          = 'en';
  bool   _darkTheme             = false;
  bool   _runInBackground       = false;
  bool   _startOnBoot           = false;
  bool   _disableBatteryOpt     = false;
  bool   _keepScreenOn          = false;
  String _defaultConnection     = 'none';
  String _orientation           = 'Portrait';
  String _dashboardPlacement    = 'Bottom Bar';

  // ── Getters ────────────────────────────────────────────────
  String get languageCode          => _languageCode;
  bool   get darkTheme             => _darkTheme;
  bool   get runInBackground       => _runInBackground;
  bool   get startOnBoot           => _startOnBoot;
  bool   get disableBatteryOpt     => _disableBatteryOpt;
  bool   get keepScreenOn          => _keepScreenOn;
  String get defaultConnection     => _defaultConnection;
  String get orientation           => _orientation;
  String get dashboardPlacement    => _dashboardPlacement;

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _languageCode       = _prefs!.getString(_keyLanguage)           ?? 'en';
    _darkTheme          = _prefs!.getBool(_keyDarkTheme)            ?? false;
    _runInBackground    = _prefs!.getBool(_keyRunInBackground)      ?? false;
    _startOnBoot        = _prefs!.getBool(_keyStartOnBoot)          ?? false;
    _disableBatteryOpt  = _prefs!.getBool(_keyDisableBattery)       ?? false;
    _keepScreenOn       = _prefs!.getBool(_keyKeepScreenOn)         ?? false;
    _defaultConnection  = _prefs!.getString(_keyDefaultConnection)  ?? 'none';
    _orientation        = _prefs!.getString(_keyOrientation)        ?? 'Portrait';
    _dashboardPlacement = _prefs!.getString(_keyDashboardPlacement) ?? 'Bottom Bar';
    notifyListeners();
  }

  // ── Setters (persist + notify) ─────────────────────────────
  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await _prefs?.setString(_keyLanguage, code);
    notifyListeners();
  }

  Future<void> setDarkTheme(bool v) async {
    _darkTheme = v;
    await _prefs?.setBool(_keyDarkTheme, v);
    notifyListeners();
  }

  Future<void> setRunInBackground(bool v) async {
    _runInBackground = v;
    await _prefs?.setBool(_keyRunInBackground, v);
    notifyListeners();
  }

  Future<void> setStartOnBoot(bool v) async {
    _startOnBoot = v;
    await _prefs?.setBool(_keyStartOnBoot, v);
    notifyListeners();
  }

  Future<void> setDisableBatteryOpt(bool v) async {
    _disableBatteryOpt = v;
    await _prefs?.setBool(_keyDisableBattery, v);
    notifyListeners();
  }

  Future<void> setKeepScreenOn(bool v) async {
    _keepScreenOn = v;
    await _prefs?.setBool(_keyKeepScreenOn, v);
    notifyListeners();
  }

  Future<void> setDefaultConnection(String v) async {
    _defaultConnection = v;
    await _prefs?.setString(_keyDefaultConnection, v);
    notifyListeners();
  }

  Future<void> setOrientation(String v) async {
    _orientation = v;
    await _prefs?.setString(_keyOrientation, v);
    notifyListeners();
  }

  Future<void> setDashboardPlacement(String v) async {
    _dashboardPlacement = v;
    await _prefs?.setString(_keyDashboardPlacement, v);
    notifyListeners();
  }
}