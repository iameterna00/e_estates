import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 350,
                child: Image.asset('assets/icons/familyTravel.png'),
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
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
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
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
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
                    onPressed: _handleEmailSignIn,
                    child: const Text(
                      'Login',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    // Use the theme's default text color and font size for the first part of the text
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 16),
                    children: <TextSpan>[
                      const TextSpan(text: 'Do not have an account? '),
                      TextSpan(
                        text: 'SignUp',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(context, '/signup');
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
            ]),
          ),
        ),
      ),
      /*   floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.of(context).pushNamed('/phoneverification');
      }), */
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

        // Check if it's the first time the user is signing in
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': userCredential.user!.email,
            'username': userCredential.user!.displayName,
            'uid': userCredential.user!.uid,
            'profileUrl': userCredential.user!.photoURL,
            'followers': [],
            'following': [],
          });
        }

        // Navigate to homepage
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

  Future<void> _handleEmailSignIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
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
