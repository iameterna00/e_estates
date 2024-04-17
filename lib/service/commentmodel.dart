import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/comment_models.dart'; // Ensure this model includes userProfileUrl
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget buildComments(
  BuildContext context,
  String postId,
  ScrollController scrollController,
) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      List<Comment> comments =
          snapshot.data!.docs.map((doc) => Comment.fromDocument(doc)).toList();
      if (comments.isEmpty) {
        return const Center(
          child: Text(
            "No comments yet...",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        );
      }

      return ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          Comment comment = comments[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: comment.userProfileUrl.isNotEmpty
                  ? NetworkImage(comment.userProfileUrl)
                  : null,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showCommentsBottomSheet(BuildContext context, String postId) {
  final TextEditingController commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.90,
        minChildSize: 0.5,
        maxChildSize: 1,
        builder: (BuildContext context, ScrollController scrollController) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.drag_handle_rounded),
                  Expanded(
                    child: buildComments(context, postId, scrollController),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                          ),
                          minLines: 1,
                          maxLines: 4,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (commentController.text.trim().isEmpty) {
                            return;
                          }
                          _submitComment(
                              postId, commentController.text.trim(), context);
                          commentController.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _submitComment(
    String postId, String content, BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("You're not logged in")));
    return;
  }
  final String userId = auth.currentUser!.uid;
  final DateTime timestamp = DateTime.now();

  String userProfileUrl = '';
  String username = '';

  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final data = userDoc.data();
  if (data is Map<String, dynamic>) {
    userProfileUrl = data['profileUrl'] ?? '';
    username = data['username'];
  }

  await FirebaseFirestore.instance.collection('comments').add({
    'postId': postId,
    'userId': userId,
    'content': content,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'userProfileUrl': userProfileUrl,
    'username': username,
  });
}
