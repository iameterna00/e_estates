import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userPhotoURLProvider = StateProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.photoURL;
});
