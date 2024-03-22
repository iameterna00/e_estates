import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.watch(authStateChangesProvider));
});

class UserState {
  final String? name;
  final String? photoURL;
  final String? uid;

  UserState({
    this.name,
    this.photoURL,
    this.uid,
  });
}

class UserNotifier extends StateNotifier<UserState> {
  final AsyncValue<User?> user;
  UserNotifier(this.user) : super(UserState()) {
    user.whenData((user) {
      state = UserState(
          name: user?.displayName, photoURL: user?.photoURL, uid: user?.uid);
    });
  }
}
