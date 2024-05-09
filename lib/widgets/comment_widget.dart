import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/my_profilepage.dart';
import 'package:e_estates/pages/user_profile.dart';
import 'package:e_estates/stateManagement/comments_reply_provider.dart';
import 'package:e_estates/stateManagement/fetch_user_uid.dart';
import 'package:e_estates/stateManagement/user_uid.dart';
import 'package:flutter/material.dart';
import 'package:e_estates/models/comment_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

final replyControllersProvider = StateProvider.autoDispose
    .family<TextEditingController, String>((ref, commentId) {
  return TextEditingController();
});
final activeReplyProvider = StateProvider<String?>((ref) => null);

final replyVisibilityProvider =
    StateProvider.family<bool, String>((ref, commentId) => false);

class CommentsWidget extends ConsumerWidget {
  final String postId;

  const CommentsWidget({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsyncValue = ref.watch(commentsProvider(postId));

    return commentsAsyncValue.when(
      data: (comments) {
        if (comments.isEmpty) {
          return const Center(child: Text("No comments yet..."));
        }
        return Comments(
          comments: comments,
          postId: postId,
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
    );
  }
}

class Comments extends ConsumerWidget {
  final List<Comment> comments;
  final String postId;

  const Comments({super.key, required this.comments, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return buildCommentTile(context, ref, comments[index]);
      },
    );
  }

  Widget buildCommentTile(
      BuildContext context, WidgetRef ref, Comment comment) {
    bool isNavigating = false;

    return Column(
      children: [
        ListTile(
          leading: InkWell(
            onTap: () async {
              if (isNavigating) return;
              isNavigating = true;
              try {
                UserModel userModel = await fetchUserModelByUid(comment.userId);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => comment.userId == getCurrentUserId()
                      ? const MyProfilePage()
                      : UserProfilePage(user: userModel),
                ));
              } finally {
                isNavigating = false;
              }
            },
            child: CircleAvatar(
              backgroundImage: comment.userProfileUrl.isNotEmpty
                  ? NetworkImage(comment.userProfileUrl)
                  : null,
            ),
          ),
          title: Text(comment.username,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(comment.content,
              style: GoogleFonts.raleway(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Colors.grey)),
          trailing: Text(timeago.format(comment.timestamp),
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ),
        if (ref.watch(activeReplyProvider) == comment.id)
          Consumer(builder: (context, ref, _) {
            final replyController =
                ref.watch(replyControllersProvider(comment.id));

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: TextField(
                style: Theme.of(context).textTheme.bodyMedium,
                controller: replyController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Write a reply...",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () =>
                        submitReply(comment.id, ref, replyController),
                  ),
                ),
              ),
            );
          }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.transparent)),
              onPressed: () => ref
                  .read(replyVisibilityProvider(comment.id).notifier)
                  .state = !ref.read(replyVisibilityProvider(comment.id)),
              child: ref.watch(replyVisibilityProvider(comment.id))
                  ? const Text("Hide Replies",
                      style: TextStyle(color: Colors.blue))
                  : ref.watch(replyCountProvider(comment.id)).when(
                        data: (count) => Text("View Replies ($count)",
                            style: const TextStyle(color: Colors.blue)),
                        loading: () => const Text("Loading replies...",
                            style: TextStyle(color: Colors.grey)),
                        error: (error, stack) => const Text(
                            "Error loading replies",
                            style: TextStyle(color: Colors.red)),
                      ),
            ),
            TextButton(
              onPressed: () {
                // Toggle the active reply to this comment's ID or null if it's already active
                ref.read(activeReplyProvider.notifier).state =
                    (ref.read(activeReplyProvider) == comment.id)
                        ? null
                        : comment.id;
              },
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.transparent)),
              child: ref.watch(activeReplyProvider) == comment.id
                  ? const Text("Cancel", style: TextStyle(color: Colors.blue))
                  : const Text("Reply", style: TextStyle(color: Colors.blue)),
            )
          ],
        ),
        if (ref.watch(replyVisibilityProvider(comment.id)))
          buildReplies(context, comment.id, ref)
        else
          const SizedBox(),
      ],
    );
  }

  Widget buildReplies(BuildContext context, String commentId, WidgetRef ref) {
    final repliesAsyncValue = ref.watch(repliesProvider(commentId));

    return repliesAsyncValue.when(
      data: (replies) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: replies.length,
            itemBuilder: (context, index) {
              Comment reply = replies[index];
              return ListTile(
                leading: CircleAvatar(
                    backgroundImage: reply.userProfileUrl.isNotEmpty
                        ? NetworkImage(reply.userProfileUrl)
                        : null,
                    child: reply.userProfileUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null),
                title:
                    Text(reply.username, style: const TextStyle(fontSize: 14)),
                subtitle: Text(reply.content),
                trailing: Text(timeago.format(reply.timestamp),
                    style: const TextStyle(fontSize: 10)),
              );
            },
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Error loading replies: $e'),
    );
  }

  void submitReply(
      String commentId, WidgetRef ref, TextEditingController replyController) {
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
      // Clear the controller on successful submission
      replyController.clear();
    }).catchError((error) {
      // Handle any errors here
      print("Failed to add reply: $error");
    });
  }
}
