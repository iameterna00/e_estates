import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  AppThemes._();
  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.raleway(color: Colors.black),
        titleLarge: GoogleFonts.raleway(color: Colors.black),
        bodySmall: GoogleFonts.raleway(color: Colors.black),
        bodyLarge: GoogleFonts.raleway(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        titleSmall: GoogleFonts.raleway(color: Colors.black),
        titleMedium: GoogleFonts.raleway(color: Colors.black),
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
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
            color: Colors.black), // Color of icons in the AppBar
      ),
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(backgroundColor: Colors.black),
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
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(31, 79, 79, 79),
      textTheme: GoogleFonts.ralewayTextTheme(TextTheme(
        bodyMedium: GoogleFonts.raleway(color: Colors.white),
        titleLarge: GoogleFonts.raleway(color: Colors.white),
        bodySmall: GoogleFonts.raleway(color: Colors.white),
        bodyLarge: GoogleFonts.raleway(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      )),
      cardTheme: const CardTheme(
        color: Colors.black,
      ),
      //iconTheme: const IconThemeData(color: Colors.blue),
      bottomAppBarTheme:
          const BottomAppBarTheme(color: Colors.transparent, elevation: 0),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: const MaterialStatePropertyAll(
                  Color.fromARGB(255, 255, 255, 255)),
              elevation: MaterialStateProperty.all(4),
              backgroundColor: const MaterialStatePropertyAll(Colors.black))),
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(backgroundColor: Colors.blue));
}
