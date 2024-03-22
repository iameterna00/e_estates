import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context).pushReplacementNamed('/homepage');
      } else {
        Navigator.of(context).pushReplacementNamed('/signup');
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
