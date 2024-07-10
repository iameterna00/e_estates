import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/stateManagement/user_uid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentUtils {
  static void submitReply(String commentId, WidgetRef ref,
      TextEditingController replyController, String postId) async {
    String replyContent = replyController.text.trim();

    if (replyContent.isEmpty) {
      // Optionally handle empty reply case
      return;
    }

    try {
      String userId = getCurrentUserId();
      String? username = await getCurrentUsername();
      String? userProfileUrl = await getCurrentUserProfile();

      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .add({
        'content': replyContent,
        'userId': userId,
        'username': username,
        'postId': postId,
        'userProfileUrl': userProfileUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      replyController
          .clear(); // Clear the text field after successful submission
    } catch (error) {
      print("Failed to add reply: $error");
      // Optionally handle error, e.g., show an error message to the user
    }
  }
}
