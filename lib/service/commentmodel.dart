import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/service/comment_functions.dart';
import 'package:e_estates/widgets/comment_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showCommentsBottomSheet(
  BuildContext context,
  String postId,
  bool isBottomsheet,
) {
  final TextEditingController commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();

  showModalBottomSheet(
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white,
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
                    child: SingleChildScrollView(
                      child: CommentsWidget(
                        postId: postId,
                        isBottomSheet: true,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final activeReplyId = ref.watch(activeReplyProvider);
                          return activeReplyId != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    ref
                                        .read(activeReplyProvider.notifier)
                                        .state = null;
                                    commentController.clear();
                                    commentFocusNode.requestFocus();
                                  },
                                )
                              : SizedBox(); // Return an empty SizedBox if activeReplyId is null
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final activeReplyId =
                                    ref.watch(activeReplyProvider);
                                final hintText = activeReplyId != null
                                    ? "Reply to username"
                                    : "Write a comment...";
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (activeReplyId != null) {
                                    commentFocusNode.requestFocus();
                                  }
                                });

                                return TextField(
                                  focusNode: commentFocusNode,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    fillColor: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black
                                        : Colors.grey[300],
                                    hintText: hintText,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                  ),
                                  minLines: 1,
                                  maxLines: 4,
                                );
                              },
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final activeReplyId =
                                  ref.watch(activeReplyProvider);

                              return IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  if (commentController.text.trim().isEmpty) {
                                    return;
                                  }
                                  if (activeReplyId != null) {
                                    // Submit a reply
                                    CommentUtils.submitReply(activeReplyId, ref,
                                        commentController, postId);
                                    ref
                                        .read(activeReplyProvider.notifier)
                                        .state = null; // Reset active reply
                                  } else {
                                    // Submit a comment
                                    submitComment(postId,
                                        commentController.text.trim(), context);
                                  }
                                  commentController.clear();
                                },
                              );
                            },
                          ),
                        ],
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

Future<void> submitComment(
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
