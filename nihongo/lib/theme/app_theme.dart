import 'package:flutter/material.dart';

class AppColors {
  static const blue = Color(0xFF4F96E8);
  static const darkText = Color(0xFF555A60);
  static const placeholder = Color(0xFFA8AAAC);
  static const border = Color(0xFFE1E2E4);
  static const googleBackground = Color(0xFFFCEBEC);
  static const googleRed = Color(0xFFD83A3A);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
    ),
    fontFamily: 'Roboto',
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.blue,
      selectionHandleColor: AppColors.blue,
    ),
  );
}