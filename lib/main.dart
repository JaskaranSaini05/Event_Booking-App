import 'package:flutter/material.dart';
import 'custom_themes/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const EventBookingApp());
}

class EventBookingApp extends StatelessWidget {
  const EventBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeData,
      home: const SplashScreen(),
    );
  }
}
