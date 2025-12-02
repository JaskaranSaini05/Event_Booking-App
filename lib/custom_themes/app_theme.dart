import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color colorPrimary = Color(0xFF663DE8);
  static const Color colorSecondary = Color(0xFF7986CB);
  static const Color colorAccent = Color(0xFFFF5722);
  static const Color colorAccentLight = Color(0xFFFFE1CC);
  static const Color colorTextColor = Color(0xFF51575D);
  static const Color colorLightGrey = Color(0xFFD8D8D8);

  // Added missing colors your UI expects:
  static const Color backgroundColor = Colors.white;
  static const Color lightGrey =
      colorLightGrey; // alias to existing colorLightGrey
  static const Color textPrimary =
      colorTextColor; // alias to existing colorTextColor
  static const Color textSecondary = Colors.grey;

  static final ThemeData lightThemeData = ThemeData(
    primaryColor: colorPrimary,
    colorScheme: ColorScheme.light(
      primary: colorPrimary,
      secondary: colorSecondary,
      tertiary: colorAccentLight,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Satoshi',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: colorAccent,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorAccent,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(colorAccent),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorTextColor,
      actionTextColor: colorLightGrey,
    ),
  );
}
