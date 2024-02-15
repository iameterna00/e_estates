import 'package:e_estates/service/varification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayname = TextEditingController();
  User? _user;

  @override
  void initState() {
    super.initState();
    listenToAuthState();
  }

  void listenToAuthState() {
    _auth.authStateChanges().listen((User? user) {
      setState(() => _user = user);
    });
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.house,
                    size: 175,
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      children: [
                        Text(
                          "Hello!",
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: _displayname,
                  decoration: const InputDecoration(labelText: 'Name'),
                  keyboardType: TextInputType.name,
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true, // Hide password input
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
                      onPressed: _handleEmailSignUp,
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
                              color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(context, '/login');
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
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: googleSignInButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget googleSignInButton() {
    return Center(
      child: SizedBox(
        height: 50,
        width: 250,
        child: SignInButton(
          Buttons.google,
          text: "Sign up with Google",
          onPressed: _handleGoogleSignIn,
        ),
      ),
    );
  }

  void _handleGoogleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
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

        // Check if sign in was successful
        if (userCredential.user != null) {
          // Navigate to the HomePage if the sign-in was successful
          Navigator.of(context).pushReplacementNamed('/homepage');
        }
      } catch (error) {
        print("Failed to sign in with Google: $error");
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
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Optionally, navigate to another screen upon successful sign-in
      // Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      showError(error.toString());
    }
  }

  Future<void> _handleEmailSignUp() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.updateProfile(displayName: _displayname.text.trim());
        await user
            .reload(); // Reload the user information to ensure the update takes effect

        // Now that the display name is set, send the verification email
        await user.sendEmailVerification();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => VerificationWaitingScreen()));
        // Inform the user to check their email for verification link
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Verification email has been sent. Please check your email.'),
          ),
        );
        // Optionally, sign the user out until they verify their email
        // await _auth.signOut();
      }
    } catch (error) {
      showError(error.toString());
    }
  }
}
