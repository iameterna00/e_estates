import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final followedUsersStreamProvider =
    StreamProvider.family<List<UserModel>, String>((ref, currentUserId) {
  final followingStream = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .snapshots()
      .map((snapshot) => snapshot.data()?['following'] as List<dynamic>? ?? []);

  // Convert the stream of "following" user IDs into a stream of lists of UserModel
  return followingStream.asyncMap((followingList) async {
    List<UserModel> followedUsers = [];
    for (String userId in followingList) {
      try {
        final userDocSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDocSnapshot.exists) {
          followedUsers.add(UserModel.fromMap(userDocSnapshot.data()!));
        }
      } catch (e) {
        // Handle errors, for example by continuing to the next user ID
        continue;
      }
    }
    return followedUsers;
  });
});
