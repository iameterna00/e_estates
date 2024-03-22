import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userListProvider =
    StateNotifierProvider<UserListNotifier, List<UserModel>>((ref) {
  return UserListNotifier();
});

class UserListNotifier extends StateNotifier<List<UserModel>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserListNotifier() : super([]) {
    fetchUsers();
  }

  Future<void> fetchUsers({String searchQuery = ''}) async {
    Query query = _firestore.collection('users').orderBy('username');

    if (searchQuery.isNotEmpty) {
      query = query
          .where('username', isGreaterThanOrEqualTo: searchQuery)
          .where('username', isLessThan: '$searchQuery\uf8ff');
    }

    final snapshot = await query.limit(20).get(); // Adjust the limit as needed

    List<UserModel> users =
        snapshot.docs.map((doc) => UserModel.fromSnap(doc)).toList();
    if (searchQuery.isEmpty) {
      // If not searching, update the entire state
      state = users;
    } else {
      print('Search results: ${users.map((user) => user.username).join(', ')}');
    }
  }

  void fetchMoreUsers() => ();
}
