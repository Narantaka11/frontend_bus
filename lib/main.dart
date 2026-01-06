import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/service/session_manager.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const BusBookingApp());
}

class BusBookingApp extends StatelessWidget {
  const BusBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: SessionManager.isLoggedIn(),
        builder: (context, snapshot) {
          // Loading sebentar saat cek session
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Kalau masih login (token ada & belum expired)
          if (snapshot.data == true) {
            return const HomeScreen();
          }

          // Kalau belum login / session expired
          return const OnboardingScreen();
        },
      ),
    );
  }
}
