import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../models/usermodel.dart';

class VerificationWaitingScreen extends StatefulWidget {
  final String? username;

  const VerificationWaitingScreen({super.key, this.username});

  @override
  State<VerificationWaitingScreen> createState() =>
      _VerificationWaitingScreenState();
}

class _VerificationWaitingScreenState extends State<VerificationWaitingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.email).get();
    return UserModel.fromSnap(snap);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> checkEmailVerified() async {
      User? user = _auth.currentUser;
      await user?.reload();
      user = _auth.currentUser; // Re-fetch the updated user

      if (user != null && user.emailVerified) {
        String username = widget.username!;
        final User currentUser = _auth.currentUser!; // Corrected class name

        UserModel user = UserModel(
          email: currentUser.email ?? '',
          photoUrl: '',
          username: username,
          uid: currentUser.uid,
          followers: [],
          following: [],
          number: '',
        );
        await _firestore.collection('users').doc(user.uid).set(user.toJson());

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/completeprofile');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Your email has not been verified yet. Please check your inbox.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      }
    }

    Future<void> resendVerificationEmail(BuildContext context) async {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            content: Text(
              'Verification email has been resent.\n Please check your inbox.',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: Image.asset('assets/icons/varification.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0.0)),
                        ),
                        onPressed: checkEmailVerified,
                        child: const Text(
                          'I have verified my email',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 0.0)),
                      ),
                      onPressed: () => resendVerificationEmail(context),
                      child: const Text(
                        'Resend email',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'A verification email has been sent to your email address.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
