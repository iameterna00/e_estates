import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final likeStateProvider =
    StateNotifierProvider.family<LikeStateNotifier, LikeState, String>(
        (ref, postId) {
  return LikeStateNotifier(postId);
});

class LikeStateNotifier extends StateNotifier<LikeState> {
  final String postId;
  late final StreamSubscription<DocumentSnapshot> _subscription;

  LikeStateNotifier(this.postId)
      : super(LikeState(isLiked: false, likeCount: 0)) {
    // Start listening to the post's like changes
    _subscription = FirebaseFirestore.instance
        .collection('image')
        .doc(postId)
        .snapshots()
        .listen((snapshot) {
      final List likedUsers = snapshot.data()?['likedUsers'] ?? [];
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final isLiked = likedUsers.contains(currentUserId);
      final likeCount = likedUsers.length;

      state = LikeState(isLiked: isLiked, likeCount: likeCount);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final postRef = FirebaseFirestore.instance.collection('image').doc(postId);

    if (state.isLiked) {
      postRef.update({
        'likedUsers': FieldValue.arrayRemove([currentUser.uid]),
      });
    } else {
      postRef.update({
        'likedUsers': FieldValue.arrayUnion([currentUser.uid]),
      });
    }
  }
}

class LikeState {
  bool isLiked;
  int likeCount;
  LikeState({required this.isLiked, required this.likeCount});
}
