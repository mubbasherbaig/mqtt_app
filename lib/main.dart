import 'package:flutter/material.dart';
import 'package:mqtt_app/screens/app_settings.dart';
import 'package:provider/provider.dart';
import 'screens/connections_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  final appSettings = AppSettings();
  await appSettings.init();

  runApp(
    ChangeNotifierProvider<AppSettings>.value(
      value: appSettings,
      child: const MqttApp(),
    ),
  );
}

class MqttApp extends StatelessWidget {
  const MqttApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return MaterialApp(
      title: 'MQTT Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: settings.darkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const ConnectionsScreen(),
    );
  }
}