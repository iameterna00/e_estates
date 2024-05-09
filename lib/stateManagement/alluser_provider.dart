import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allUsersProvider = FutureProvider<Map<String, UserModel>>((ref) async {
  QuerySnapshot usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();
  Map<String, UserModel> usersMap = {};
  for (var doc in usersSnapshot.docs) {
    final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
    usersMap[user.uid] = user;
  }
  return usersMap;
});

final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userProfileProvider =
    StreamProvider.autoDispose.family<DocumentSnapshot?, String>((ref, uid) {
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
});
