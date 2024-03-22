import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/service/varification.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayname = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    _displayname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 350,
                      child: Image.asset('assets/icons/Find.png'),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "We are excited to have you! \nClick 'Sign Up'. ",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextField(
                      controller: _displayname,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                          labelStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                          labelText: 'Name'),
                      keyboardType: TextInputType.name,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                    ),
                    TextField(
                      controller: _emailController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                          labelStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                          labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: _passwordController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureText,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await _handleEmailSignUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              username: _displayname.text.trim(),
                            );
                            if (mounted) {
                              setState(() {
                                _isLoading = false; // Stop loading
                              });
                            }
                          },
                          child: const Text(
                            'Sign Up',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium, // Default text style
                          children: <TextSpan>[
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      child: Text("or"),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 250,
                          child: googleSignInButton(),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
              visible: _isLoading,
              child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  )))
        ],
      ),
    );
  }

  Widget googleSignInButton() {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      onPressed: _handleGoogleSignIn,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/icons/google.png",
            scale: 30,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Sign up with Google',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGoogleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'profileUrl': userCredential.user!.photoURL,
            'username': userCredential.user!.displayName,
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'followers': [],
            'following': [],
          });
        }

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/homepage');
        }
      } catch (error) {
        String errorMessage = error.toString();
        errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]:?\s?'), '');
        showError(errorMessage);
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  Future<String> _handleEmailSignUp({
    required String email,
    required String password,
    required String username,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        User? user = userCredential.user;

        if (user != null && !user.emailVerified) {
          await user.updateDisplayName(username);
          await user.sendEmailVerification();

          if (mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => VerificationWaitingScreen(
                      username: username,
                    )));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Verification email has been sent. Please check your email.'),
              ),
            );
          }
          res = "Verification email sent";
        } else {}
      }
    } catch (error) {
      String errorMessage = error.toString();
      errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]:?\s?'), '');
      showError(
          errorMessage); // Assuming showError is defined to handle showing the error
      res = "Error: $errorMessage";
    }

    return res;
  }
}
