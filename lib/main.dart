import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/service/session_manager.dart';

import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_booking_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_bus_screen.dart';
import 'screens/admin/admin_route_screen.dart';
import 'screens/admin/admin_user_screen.dart';

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

      // ================= ROUTES (TANPA PARAMETER) =================
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/admin/bookings': (_) => const AdminBookingScreen(),
        '/admin/dashboard': (_) => const AdminDashboardScreen(),
        '/admin/buses': (_) => const AdminBusScreen(),
        '/admin/routes': (_) => const AdminRouteScreen(),
        '/admin/users': (_) => const AdminUserScreen(),
      },

      // ================= INITIAL LOGIC =================
      home: FutureBuilder<String?>(
        future: SessionManager.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<String?>(
              future: SessionManager.getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (roleSnapshot.data == 'ADMIN') {
                  return const AdminDashboardScreen();
                }
                return const HomeScreen();
              },
            );
          }

          return const OnboardingScreen();
        },
      ),
    );
  }
}
