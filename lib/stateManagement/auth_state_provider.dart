import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier(ref.watch(authStateChangesProvider));
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier(AsyncValue<User?> userStream) : super(null) {
    userStream.whenData((user) {
      if (user != null) {
        fetchUserData(user.uid);
      } else {
        state = null;
      }
    });
  }

  void fetchUserData(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      state = UserModel.fromSnap(userDoc);
    } else {
      state = UserModel.empty();
    }
  }
}
