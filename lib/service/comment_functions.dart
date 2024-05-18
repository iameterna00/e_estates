import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/stateManagement/user_uid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentUtils {
  static void submitReply(String commentId, WidgetRef ref,
      TextEditingController replyController, String postId) {
    if (replyController.text.isEmpty) {
      // Optionally handle the empty input case, e.g., show an error message
      return;
    }

    FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .add({
      'content': replyController.text,
      'userId': getCurrentUserId(),
      'username': getCurrentUsername(),
      'postId': postId,
      'userProfileUrl': getCurrentUserProfile(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }).then((value) {
      replyController.clear();
    }).catchError((error) {
      print("Failed to add reply: $error");
    });
  }
}
