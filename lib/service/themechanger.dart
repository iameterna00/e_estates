import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  AppThemes._();
  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.raleway(color: Colors.black),
        titleLarge: GoogleFonts.raleway(color: Colors.black),
        bodySmall: GoogleFonts.raleway(color: Colors.black),
        bodyLarge: GoogleFonts.raleway(
          color: Colors.black,
        ),
        titleSmall: GoogleFonts.raleway(color: Colors.black),
        titleMedium: GoogleFonts.raleway(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.all(Colors.blue))),
      appBarTheme: AppBarTheme(
        color: Colors.white,
        titleTextStyle: GoogleFonts.raleway(
            color: Colors.black,
            fontSize: 20), // Color of the AppBar in the light theme
        iconTheme: const IconThemeData(
            color: Colors.blue), // Color of icons in the AppBar
      ),
      bottomAppBarTheme:
          const BottomAppBarTheme(color: Colors.transparent, elevation: 0),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor:
                  const MaterialStatePropertyAll(Color(0xFF858585)),
              textStyle: MaterialStateProperty.all(GoogleFonts.raleway()),
              backgroundColor:
                  const MaterialStatePropertyAll(Color(0xFFF7F7F7)))));

  // Define the dark theme
  static ThemeData darkTheme = ThemeData(
      useMaterial3: true, // Enable Material 3 features
      brightness: Brightness.dark, // Set the overall theme brightness to dark
      primarySwatch: Colors.teal, // Primary color for the app in dark theme
      textTheme: GoogleFonts.ralewayTextTheme(TextTheme(
        bodyMedium: GoogleFonts.raleway(color: Colors.white),
        titleLarge: GoogleFonts.raleway(color: Colors.white),
        bodySmall: GoogleFonts.raleway(color: Colors.white),
        bodyLarge: GoogleFonts.raleway(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      )),
      bottomAppBarTheme:
          const BottomAppBarTheme(color: Colors.transparent, elevation: 0),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: const MaterialStatePropertyAll(
                  Color.fromARGB(255, 255, 255, 255)),
              elevation: MaterialStateProperty.all(4),
              backgroundColor: const MaterialStatePropertyAll(Colors.black))));
}
