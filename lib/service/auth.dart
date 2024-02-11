import 'package:e_estates/pages/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_estates/pages/homepage.dart';

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // Check if the snapshot has any data
          if (snapshot.hasData) {
            // User is signed in
            return HomeScreen(); // Navigate to home screen
          } else {
            // User is not signed in
            return LoginScreen(); // Navigate to login screen
          }
        }

        // Waiting for connection state to be active
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Show loading indicator
          ),
        );
      },
    );
  }
}
