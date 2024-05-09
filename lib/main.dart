import 'package:e_estates/firebase_options.dart';
import 'package:e_estates/service/route.dart';
import 'package:e_estates/service/theme.dart';
import 'package:e_estates/service/themechanger.dart';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('lightTileCache');
  await Hive.openBox('darkTileCache');

  var box = await Hive.openBox('locationBox');
  await box.clear();
  final locationNotifier = LocationNotifier();
  await locationNotifier.fetchUserLocation();

  runApp(
    const ProviderScope(child: MyApp()),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eestates',
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
