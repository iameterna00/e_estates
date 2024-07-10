import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_estates/models/comment_models.dart';
import 'package:tuple/tuple.dart';

final commentsProvider =
    StreamProvider.family<List<Comment>, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('comments')
      .where('postId', isEqualTo: postId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
  });
});
final repliesProvider =
    StreamProvider.family<List<Comment>, Tuple2<String, int>>((ref, tuple) {
  final commentId = tuple.item1;
  final limit = tuple.item2;
  return FirebaseFirestore.instance
      .collection('comments')
      .doc(commentId)
      .collection('replies')
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
  });
});

class ReplyStateNotifier extends StateNotifier<int> {
  ReplyStateNotifier() : super(10); // starts with 10 replies limit

  void loadMore() {
    state += 10;
  }
}

final replyCountLimitProvider =
    StateNotifierProvider.family<ReplyStateNotifier, int, String>(
        (ref, commentId) {
  return ReplyStateNotifier();
});

final initialRepliesProvider =
    StreamProvider.family<List<Comment>, String>((ref, commentId) {
  return FirebaseFirestore.instance
      .collection('comments')
      .doc(commentId)
      .collection('replies')
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
  });
});

final replyCountProvider = StreamProvider.family<int, String>((ref, commentId) {
  return FirebaseFirestore.instance
      .collection('comments')
      .doc(commentId)
      .collection('replies')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});
