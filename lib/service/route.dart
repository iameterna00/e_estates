import 'package:e_estates/pages/login_page.dart';
import 'package:e_estates/pages/signup_page.dart';
import 'package:e_estates/pages/home_screen.dart';
import 'package:e_estates/pages/splash_screen.dart';

import 'package:e_estates/pages/upload_image_page.dart';
import 'package:e_estates/service/theme.dart';

import 'package:e_estates/service/varification.dart';
import 'package:e_estates/widgets/location_picker.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String homepage = '/homepage';
  static const String themepage = '/themepage';
  static const String verificationWaiting = '/verificationWaiting';

  static const String uploadimage = '/picker';
  static const String topfeedDetail = '/topfeeddetail';

  static const String locationPicker = '/locationpicker';

  static Map<String, WidgetBuilder> define() {
    return {
      splash: (BuildContext context) => SplashScreen(),
      signup: (BuildContext context) => const SignUpScreen(),
      login: (BuildContext context) => const LoginScreen(),
      homepage: (BuildContext context) => const HomeScreen(),
      themepage: (BuildContext context) => ThemePage(
            onThemeChanged: (ThemeMode) {},
          ),
      verificationWaiting: (BuildContext context) =>
          VerificationWaitingScreen(),
      uploadimage: (BuildContext context) => ImageUpload(),
      locationPicker: (BuildContext context) => const LocationPickerMap(),
      // locationPicker: (BuildContext context) => const LocationPickerMap(),
    };
  }
}
