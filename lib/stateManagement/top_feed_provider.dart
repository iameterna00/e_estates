import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_estates/models/image_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final topFeedProvider =
    StateNotifierProvider<TopFeedNotifier, AsyncValue<List<ImagePost>>>((ref) {
  return TopFeedNotifier(ref: ref);
});

class TopFeedNotifier extends StateNotifier<AsyncValue<List<ImagePost>>> {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TopFeedNotifier({required this.ref}) : super(const AsyncLoading()) {
    fetchhPosts();
  }

  Future<void> fetchhPosts() async {
    try {
      final posts = await fetchPost();
      state = AsyncValue.data(posts);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<List<ImagePost>> fetchPost() async {
    QuerySnapshot snapshot = await _firestore.collection('image').get();

    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return [];
    }
    return snapshot.docs
        .map((doc) => ImagePost.fromDocument(doc, currentUserId))
        .toList();
  }

  String? yourMethodToGetCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> refreshPosts() async {
    print('refreshing posts...');
    fetchhPosts();
  }
}
