import 'package:firebase_auth/firebase_auth.dart';

String getCurrentUserId() {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;

  // Return the user ID if available, or a default value if no user is logged in
  return user?.uid ?? 'default-user-id';
}

String? getCurrentUserProfile() {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get the current user
  final User? user = auth.currentUser;

  // Return the user ID if available, or null if no user is logged in
  return user?.photoURL;
}

String? getCurrentUsername() {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get the current user
  final User? user = auth.currentUser;

  // Return the user ID if available, or null if no user is logged in
  return user?.displayName;
}
