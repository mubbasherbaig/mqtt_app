import 'package:flutter/material.dart';
import 'package:mqtt_app/screens/app_settings.dart';
import 'package:provider/provider.dart';
import 'screens/connections_screen.dart';
import 'services/storage_service.dart';
import 'services/multi_mqtt_service.dart';
import 'services/notification_service.dart';
import 'services/background_mqtt_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await NotificationService.init();
  await initBackgroundService();   // register channels + configure service

  final appSettings = AppSettings();
  await appSettings.init();

  final mqttService = MultiMqttService();
  await mqttService.init();        // UI-side MQTT connections (for live panels)

  await startBackgroundKeepAlive(); // start bg isolate — owns its own MQTT + notifications

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettings>.value(value: appSettings),
        ChangeNotifierProvider<MultiMqttService>.value(value: mqttService),
      ],
      child: const MqttApp(),
    ),
  );
}

class MqttApp extends StatefulWidget {
  const MqttApp({super.key});

  @override
  State<MqttApp> createState() => _MqttAppState();
}

class _MqttAppState extends State<MqttApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[App] Resumed — reconnecting UI MQTT');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) context.read<MultiMqttService>().resumeAll();
      });
    }
  }

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