import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? _verificationId;
  bool _isOTPSent = false;

  void _verifyPhoneNumber() async {
    verificationCompleted(PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      setState(() {
        _isOTPSent = true;
      });
      print(
          'Phone number automatically verified and user signed in: ${_auth.currentUser!.uid}');
    }

    verificationFailed(FirebaseAuthException e) {
      print(
          'Phone number verification failed. Code: ${e.code}. Message: ${e.message}');
    }

    codeSent(String verificationId, int? resendToken) async {
      print('Please check your phone for the verification code.');
      _verificationId = verificationId;
    }

    codeAutoRetrievalTimeout(String verificationId) {
      _verificationId = verificationId;
    }

    await _auth.verifyPhoneNumber(
        phoneNumber: '+977${_phoneController.text}',
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<void> _signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      final User? user = (await _auth.signInWithCredential(credential)).user;

      print("Successfully signed in UID: ${user!.uid}");
    } catch (e) {
      print("Failed to sign in: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 350,
              child: Image.asset('assets/icons/Find.png'),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Enter your Phone Number',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (!_isOTPSent)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // allow only digits
                    LengthLimitingTextInputFormatter(10), // limit to 10 digits
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Image.asset(
                      'assets/icons/nepalflag.png',
                      scale: 20,
                    ),
                    prefix: const Text('+977'), // country code
                    hintText: 'Enter your phone number',
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: _verifyPhoneNumber,
              child: const Text("Generate OTP"),
              //style: TextButton.styleFrom(backgroundColor: Colors.blue),
            ),
            if (_isOTPSent)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: PinCodeTextField(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  appContext: context,
                  length: 6,
                  keyboardType:
                      TextInputType.number, // restrict input to numbers
                  obscureText: false,
                  animationType: AnimationType.none, // remove animation
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 40,
                    fieldWidth: 40,
                    activeColor: Colors.blue, // simple color for active field
                    inactiveColor:
                        Colors.grey, // simple color for inactive field
                    selectedColor:
                        Colors.grey, // simple color for selected field
                  ),
                  controller: _codeController,
                  onCompleted: (v) {
                    print("Completed");
                  },
                  onChanged: (value) {
                    print(value);
                  },
                ),
              ),
            if (_isOTPSent)
              TextButton(
                onPressed: _signInWithPhoneNumber,
                child: const Text("Sign In"),
              ),
          ],
        ),
      ),
    );
  }
}
