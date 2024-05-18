import 'package:e_estates/pages/complete_profile.dart';
import 'package:e_estates/pages/explore_page.dart';
import 'package:e_estates/pages/login_page.dart';
import 'package:e_estates/pages/numberlogin.dart';
import 'package:e_estates/pages/signup_page.dart';
import 'package:e_estates/pages/home_screen.dart';
import 'package:e_estates/pages/splash_screen.dart';
import 'package:e_estates/pages/upload_image_page.dart';
import 'package:e_estates/service/theme.dart';
import 'package:e_estates/pages/varification.dart';
import 'package:e_estates/widgets/location_picker.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String homepage = '/homepage';
  static const String themepage = '/themepage';
  static const String verificationWaiting = '/verificationWaiting';
  static const String explore = '/explore';
  static const String uploadimage = '/picker';
  static const String topfeedDetail = '/topfeeddetail';
  static const String phoneverification = '/phoneverification';
  static const String mobilescreen = '/mobilescreen';
  static const String completeprofile = '/completeprofile';

  static const String locationPicker = '/locationpicker';

  static Map<String, WidgetBuilder> define() {
    return {
      splash: (BuildContext context) => const SplashScreen(),
      phoneverification: (BuildContext context) => const PhoneAuthPage(),
      signup: (BuildContext context) => const SignUpScreen(),
      login: (BuildContext context) => const LoginScreen(),
      homepage: (BuildContext context) => const HomeScreen(),
      themepage: (BuildContext context) => ThemePage(
            onThemeChanged: (themeMode) {},
          ),
      verificationWaiting: (BuildContext context) =>
          const VerificationWaitingScreen(),
      uploadimage: (BuildContext context) => const ImageUpload(),
      completeprofile: (BuildContext context) => const CompleteProfile(),
      locationPicker: (BuildContext context) => const LocationPickerMap(),
      explore: (BuildContext context) => const ExplorePage(),
    };
  }
}
