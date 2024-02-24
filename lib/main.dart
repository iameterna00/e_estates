import 'package:e_estates/firebase_options.dart';
import 'package:e_estates/service/route.dart';
import 'package:e_estates/service/theme.dart';
import 'package:e_estates/service/themechanger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(child: MyApp()), // Wrap MyApp with ProviderScope
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  void _handleThemeChange(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Theme Demo',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: _themeMode,
        initialRoute: AppRoutes.splash,
        routes: {
          ...AppRoutes.define(),
          AppRoutes.themepage: (context) =>
              ThemePage(onThemeChanged: _handleThemeChange),
        });
  }
}
