import 'package:flutter/material.dart';

/// App color palette based on Figma design
class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFFFDF8F3);

  // Brown shades (Primary)
  static const Color brown900 = Color(0xFF7C2D12);
  static const Color brown800 = Color(0xFF9A3412);
  static const Color brown700 = Color(0xFFB45309);
  static const Color brownFont = Color(0xFFC2410C);

  // Orange gradient
  static const Color orangeGradasi = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange400 = Color(0xFFFDBA74);
  static const Color orangeButton = Color(0xFFFB923C);
  static const Color orangeSeat = Color(0xFFF97316);
  static const Color orange600 = Color(0xFFEA580C);

  // Text colors
  static const Color textDark = Color(0xFF1A3447);
  static const Color textGray = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFB8B8B8);

  // Other colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  // Seat states
  static const Color seatBooked = Color(0xFF1A1A1A);
  static const Color seatSelected = Color(0xFFF97316);
  static const Color seatAvailable = Color(0xFFE5E7EB);
}
