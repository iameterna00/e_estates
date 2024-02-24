import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_estates/service/image_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final topFeedProvider =
    StateNotifierProvider<TopFeedNotifier, AsyncValue<List<ImagePost>>>((ref) {
  return TopFeedNotifier();
});

class TopFeedNotifier extends StateNotifier<AsyncValue<List<ImagePost>>> {
  TopFeedNotifier() : super(AsyncLoading()) {
    fetchhPosts();
  }

  Future<void> fetchhPosts() async {
    print('Fetching posts...');
    try {
      final posts = await fetchPost();
      state = AsyncValue.data(posts);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  // Define the refreshPosts method
  Future<void> refreshPosts() async {
    print('refreshing posts...');
    await fetchhPosts();
  }

  Future<List<ImagePost>> fetchPost() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('image').get();
    return snapshot.docs.map((doc) => ImagePost.fromDocument(doc)).toList();
  }
}
