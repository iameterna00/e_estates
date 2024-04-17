import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:e_estates/models/usermodel.dart'; // Adjust the import path to where your UserModel is defined

Future<UserModel> fetchUserModelByUid(String uid) async {
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

  if (userDoc.exists) {
    return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  } else {
    throw Exception('User not found');
  }
}
