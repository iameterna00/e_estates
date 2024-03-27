import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileProvider =
    FutureProvider.family<UserModel, String>((ref, userId) async {
  final docSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  return UserModel.fromMap(docSnapshot.data()!);
});

Future<void> refreshUserData(WidgetRef ref, String userId) async {
  // Intentionally ignoring the result of refresh. Its purpose is to invalidate the cache.
  ref.refresh(userProfileProvider(userId));
}
