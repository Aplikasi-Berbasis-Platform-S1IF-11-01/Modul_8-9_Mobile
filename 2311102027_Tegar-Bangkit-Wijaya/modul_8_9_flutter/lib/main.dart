import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamera & Notifikasi - 2311102027',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F3FF),
        textTheme: ThemeData.light().textTheme.copyWith(
          headlineSmall: const TextStyle(fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
