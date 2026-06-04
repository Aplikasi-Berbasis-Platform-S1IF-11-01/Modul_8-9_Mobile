import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foto & Notifikasi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFFB5C8F0),
          onPrimary: const Color(0xFF3A3A5C),
          secondary: const Color(0xFFF0B5D8),
          onSecondary: const Color(0xFF5C3A50),
          error: const Color(0xFFFFB5B5),
          onError: Colors.white,
          surface: const Color(0xFFFFF9FB),
          onSurface: const Color(0xFF3A3A5C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F0FA),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}