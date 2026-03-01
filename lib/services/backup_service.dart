// lib/services/backup_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';

class BackupService {
  static const int _backupVersion = 1;

  // ── Build backup maps ───────────────────────────────────────

  static Map<String, dynamic> _buildFullBackup() {
    final connections = StorageService.loadConnections();
    final sanitized = connections.map((conn) {
      final copy = Map<String, dynamic>.from(conn);
      copy.remove('username');
      copy.remove('password');
      copy.remove('clientId');
      return copy;
    }).toList();

    return {
      'backupVersion': _backupVersion,
      'backupType': 'full',
      'createdAt': DateTime.now().toIso8601String(),
      'connections': sanitized,
    };
  }

  static Map<String, dynamic> _buildConnectionBackup(int connectionIndex) {
    final connections = StorageService.loadConnections();
    if (connectionIndex < 0 || connectionIndex >= connections.length) {
      throw Exception('Invalid connection index');
    }
    final conn = Map<String, dynamic>.from(connections[connectionIndex]);
    conn.remove('username');
    conn.remove('password');
    conn.remove('clientId');

    return {
      'backupVersion': _backupVersion,
      'backupType': 'connection',
      'createdAt': DateTime.now().toIso8601String(),
      'connection': conn,
    };
  }

  // ── Export full backup ──────────────────────────────────────

  static Future<void> exportFullBackup(BuildContext context) async {
    try {
      final backup = _buildFullBackup();
      final json = const JsonEncoder.withIndent('  ').convert(backup);
      final filename = 'mqtt_panel_full_backup_${_timestamp()}.json';
      await _saveToDevice(context, json, filename);
    } catch (e) {
      _showError(context, 'Export failed: $e');
    }
  }

  // ── Export single connection backup ────────────────────────

  static Future<void> exportConnectionBackup(
      BuildContext context,
      int connectionIndex,
      String connectionName,
      ) async {
    try {
      final backup = _buildConnectionBackup(connectionIndex);
      final json = const JsonEncoder.withIndent('  ').convert(backup);
      final safeName = connectionName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final filename = 'mqtt_panel_${safeName}_${_timestamp()}.json';
      await _saveToDevice(context, json, filename);
    } catch (e) {
      _showError(context, 'Export failed: $e');
    }
  }

  // ── Import full backup ──────────────────────────────────────

  static Future<bool> importFullBackup(BuildContext context) async {
    try {
      final content = await _pickFile(context);
      if (content == null) return false;

      final data = jsonDecode(content) as Map<String, dynamic>;

      if (data['backupType'] != 'full') {
        _showError(context,
            'This is a single connection backup. Use "Import Connection Backup" instead.');
        return false;
      }

      final connections = (data['connections'] as List)
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();

      final confirmed = await _confirmRestore(
        context,
        'This will REPLACE all your current dashboards and panels.\n'
            'Broker credentials will need to be re-entered.\n\nContinue?',
      );
      if (confirmed != true) return false;

      // Preserve existing credentials by matching broker+port
      final existing = StorageService.loadConnections();
      final merged = connections.map((imported) {
        final match = existing.firstWhere(
              (e) =>
          e['broker'] == imported['broker'] &&
              e['port'] == imported['port'],
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          imported['username'] = match['username'] ?? '';
          imported['password'] = match['password'] ?? '';
          imported['clientId'] = match['clientId'] ?? '';
        }
        return imported;
      }).toList();

      await StorageService.saveConnections(merged);
      _showSuccess(context, 'Full backup restored successfully!');
      return true;
    } catch (e) {
      _showError(context, 'Import failed: $e');
      return false;
    }
  }

  // ── Import single connection backup ────────────────────────

  static Future<bool> importConnectionBackup(
      BuildContext context,
      int connectionIndex,
      ) async {
    try {
      final content = await _pickFile(context);
      if (content == null) return false;

      final data = jsonDecode(content) as Map<String, dynamic>;

      if (data['backupType'] != 'connection') {
        _showError(context,
            'This is a full backup. Use "Import Full Backup" instead.');
        return false;
      }

      final importedConn =
      Map<String, dynamic>.from(data['connection'] as Map);

      final confirmed = await _confirmRestore(
        context,
        'This will replace all dashboards and panels for this connection.\n'
            'Broker credentials will be preserved.\n\nContinue?',
      );
      if (confirmed != true) return false;

      // Always preserve credentials from existing connection
      final connections = StorageService.loadConnections();
      if (connectionIndex >= 0 && connectionIndex < connections.length) {
        final existing = connections[connectionIndex];
        importedConn['username'] = existing['username'] ?? '';
        importedConn['password'] = existing['password'] ?? '';
        importedConn['clientId'] = existing['clientId'] ?? '';
        importedConn['broker'] = existing['broker'] ?? importedConn['broker'];
        importedConn['port'] = existing['port'] ?? importedConn['port'];
        importedConn['name'] = existing['name'] ?? importedConn['name'];
      }

      await StorageService.updateConnection(connectionIndex, importedConn);
      _showSuccess(context, 'Connection backup restored successfully!');
      return true;
    } catch (e) {
      _showError(context, 'Import failed: $e');
      return false;
    }
  }

  // ── Save file directly to Downloads folder ──────────────────

  static Future<void> _saveToDevice(
      BuildContext context,
      String json,
      String filename,
      ) async {
    if (Platform.isAndroid) {
      // Android 11+ needs MANAGE_EXTERNAL_STORAGE, older needs WRITE_EXTERNAL_STORAGE
      bool granted = false;

      if (await Permission.manageExternalStorage.isGranted) {
        granted = true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          granted = true;
        } else {
          // Fallback for Android 9/10
          final legacy = await Permission.storage.request();
          granted = legacy.isGranted;
        }
      }

      if (!granted) {
        if (context.mounted) {
          _showError(context,
              'Storage permission denied. Please grant storage access in Settings.');
        }
        return;
      }

      const downloadPath = '/storage/emulated/0/Download';
      final dir = Directory(downloadPath);
      if (!await dir.exists()) {
        try {
          await dir.create(recursive: true);
        } catch (_) {
          if (context.mounted) {
            _showError(context, 'Cannot access Downloads folder.');
          }
          return;
        }
      }

      final file = File('$downloadPath/$filename');
      await file.writeAsString(json);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Saved to Downloads/$filename'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else if (Platform.isIOS) {
      // On iOS: use NSDocumentDirectory (accessible via Files app → On My iPhone)
      // We use the app's Documents directory since direct Downloads isn't accessible
      final docsDir = await _iosDocumentsDir();
      if (docsDir == null) {
        if (context.mounted) _showError(context, 'Cannot access Documents folder.');
        return;
      }
      final file = File('${docsDir.path}/$filename');
      await file.writeAsString(json);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Saved to Files app → On My iPhone → MQTT Panel/$filename'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  static Future<Directory?> _iosDocumentsDir() async {
    // path_provider's getApplicationDocumentsDirectory equivalent
    // Using dart:io NSSearchPathDirectory equivalent
    try {
      // This path works for iOS app documents — visible in Files app
      final home = Platform.environment['HOME'] ?? '';
      if (home.isNotEmpty) {
        final docs = Directory('$home/Documents');
        if (await docs.exists()) return docs;
        return await docs.create(recursive: true);
      }
    } catch (_) {}
    return null;
  }

  // ── Pick JSON file ──────────────────────────────────────────

  static Future<String?> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return await File(path).readAsString();
  }

  // ── Helpers ─────────────────────────────────────────────────

  static String _timestamp() {
    final now = DateTime.now();
    return '${now.year}${_p(now.month)}${_p(now.day)}_'
        '${_p(now.hour)}${_p(now.minute)}${_p(now.second)}';
  }

  static String _p(int v) => v.toString().padLeft(2, '0');

  static Future<bool?> _confirmRestore(
      BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Restore'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESTORE',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void _showError(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void _showSuccess(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}