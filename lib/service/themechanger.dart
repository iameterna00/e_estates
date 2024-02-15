import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._(); // Private constructor to prevent instantiation

  // Define the light theme
  static ThemeData lightTheme = ThemeData(
      useMaterial3: true, // Enable Material 3 features
      brightness: Brightness.light, // Set the overall theme brightness to light
      primarySwatch: Colors.blue, // Primary color for the app
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // Default body text style
          titleLarge: TextStyle(color: Colors.black)), // Default font family
      // Add other customizations here, such as appBarTheme, iconTheme, etc.
      appBarTheme: const AppBarTheme(
        color: Colors.white, // Color of the AppBar in the light theme
        iconTheme:
            IconThemeData(color: Colors.blue), // Color of icons in the AppBar
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Color.fromARGB(255, 154, 208, 251),
      ));

  // Define the dark theme
  static ThemeData darkTheme = ThemeData(
      useMaterial3: true, // Enable Material 3 features
      brightness: Brightness.dark, // Set the overall theme brightness to dark
      primarySwatch: Colors.teal, // Primary color for the app in dark theme
      fontFamily: 'Roboto',
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.transparent,
      ));
}
