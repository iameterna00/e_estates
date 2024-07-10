import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileUpdate {
  static Future<void> updateUserProfileUrl(String uid, String imageUrl) async {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(uid);
    await userDoc.update({'profileUrl': imageUrl});
  }

  static Future<void> updateUserPhoneNumber(
      String userId, String phoneNumber) async {
    try {
      // Update the user's phone number in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'number': phoneNumber});
      print('number updated successfully to: $phoneNumber');
    } catch (error) {
      // Handle any errors
      print('Error updating user phone number: $error');
    }
  }

  static Future<void> updateName(String userId, String username) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'username': username});
      print('Username updated successfully to: $username');
    } catch (error) {
      print('Error updating username: $error');
    }
  }

  static Future<void> iAM(String userId, String iAm) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'iAm': iAm});
      print('option updated Iam to: $iAm');
    } catch (error) {
      print('Error updating username: $error');
    }
  }

  static Future<String> uploadImage(File imageFile, String uid) async {
    Reference ref =
        FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    await uploadTask;
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  static Future<void> requestPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      await Permission.photos.request();
    }
  }

  static Future<void> updateUserProfileOption(String uid, String option) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'option': option,
    });
  }
}
