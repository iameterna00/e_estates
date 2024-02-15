import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationWaitingScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VerificationWaitingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> checkEmailVerified() async {
      // Force a reload of the user's profile to refresh the emailVerified status
      User? user = _auth.currentUser;
      await user?.reload();
      user = _auth.currentUser; // Re-fetch the updated user

      if (user != null && user.emailVerified) {
        // Navigate to the homepage if verified
        Navigator.of(context).pushReplacementNamed('/homepage');
      } else {
        // Show a message if not verified yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Your email has not been verified yet. Please check your inbox.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }

    Future<void> resendVerificationEmail(BuildContext context) async {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Verification email has been resent. Please check your inbox.'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('A verification email has been sent to your email address.'),
            ElevatedButton(
              onPressed: checkEmailVerified,
              child: const Text('I have verified my email'),
            ),
            TextButton(
              onPressed: () => resendVerificationEmail(context),
              child: const Text('Resend email'),
            ),
          ],
        ),
      ),
    );
  }
}
