import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signin {
  static void verifyPhoneNumber(
    String? varificationId,
    TextEditingController numberController,
    Function(bool) updateOtpState,
  ) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    verificationCompleted(PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      updateOtpState(true);
    }

    verificationFailed(FirebaseAuthException e) {}

    codeSent(String verificationId, int? resendToken) async {
      varificationId = verificationId;
    }

    codeAutoRetrievalTimeout(String verificationId) {
      varificationId = verificationId;
    }

    await _auth.verifyPhoneNumber(
        phoneNumber: '+977${numberController.text}',
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }
}
