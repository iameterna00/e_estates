import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_estates/models/comment_models.dart';

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
    StreamProvider.family<List<Comment>, String>((ref, commentId) {
  return FirebaseFirestore.instance
      .collection('comments')
      .doc(commentId)
      .collection('replies')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
  });
});
final replyCountProvider =
    FutureProvider.family<int, String>((ref, commentId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('comments')
      .doc(commentId)
      .collection('replies')
      .get();
  int count = snapshot.docs.length;
  print("Fetched reply count for $commentId: $count");
  return count;
});
