import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/my_profilepage.dart';
import 'package:e_estates/pages/user_profile.dart';
import 'package:e_estates/service/comment_functions.dart';
import 'package:e_estates/stateManagement/comments_reply_provider.dart';
import 'package:e_estates/stateManagement/fetch_user_uid.dart';
import 'package:e_estates/stateManagement/user_uid.dart';
import 'package:flutter/material.dart';
import 'package:e_estates/models/comment_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tuple/tuple.dart';

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
    final bool isReplyVisible = ref.watch(replyVisibilityProvider(comment.id));
    final bool isActiveReply = ref.watch(activeReplyProvider) == comment.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  if (isNavigating) return;
                  isNavigating = true;
                  try {
                    UserModel userModel =
                        await fetchUserModelByUid(comment.userId);
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(comment.content,
                        style: GoogleFonts.raleway(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Colors.grey)),
                  ],
                ),
              ),
              Text(timeago.format(comment.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        if (!isReplyVisible)
          if (isActiveReply)
            Consumer(builder: (context, ref, _) {
              final replyController =
                  ref.watch(replyControllersProvider(comment.id));

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: replyController,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.grey[300],
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Write a reply...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => CommentUtils.submitReply(
                          comment.id, ref, replyController, postId),
                    ),
                  ),
                ),
              );
            }),
        if (ref.watch(replyVisibilityProvider(comment.id)))
          buildReplies(context, comment.id, ref)
        else
          const SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                onPressed: () => ref
                    .read(replyVisibilityProvider(comment.id).notifier)
                    .state = !ref.read(replyVisibilityProvider(comment.id)),
                child: ref.watch(replyVisibilityProvider(comment.id))
                    ? const Text("Hide Replies",
                        style: TextStyle(color: Colors.blue))
                    : ref.watch(replyCountProviders(comment.id)).when(
                          data: (count) => Text(
                            "$count Replies",
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 14),
                          ),
                          loading: () => const Text("Loading replies...",
                              style: TextStyle(color: Colors.grey)),
                          error: (error, stack) => const Text(
                              "Error loading replies",
                              style: TextStyle(color: Colors.red)),
                        ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(activeReplyProvider.notifier).state =
                      (ref.read(activeReplyProvider) == comment.id)
                          ? null
                          : comment.id;
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                child: ref.watch(activeReplyProvider) == comment.id
                    ? const Text("Cancel",
                        style: TextStyle(color: Colors.white))
                    : const Text("Reply",
                        style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildReplies(BuildContext context, String commentId, WidgetRef ref) {
    final int replyLimit = ref.watch(replyCountProvider(commentId));
    final repliesAsyncValue =
        ref.watch(repliesProvider(Tuple2(commentId, replyLimit)));
    final TextEditingController replyController =
        ref.watch(replyControllersProvider(commentId));
    final bool isReplyActive = ref.watch(activeReplyProvider) == commentId;

    return repliesAsyncValue.when(
      data: (replies) {
        bool hasMoreReplies = replies.length < replyLimit;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
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
                    title: Text(reply.username,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(reply.content),
                    trailing: Text(timeago.format(reply.timestamp),
                        style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
              if (!hasMoreReplies)
                TextButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.transparent)),
                  onPressed: () {
                    ref.read(replyCountProvider(commentId).notifier).loadMore();
                  },
                  child: const Text('View More'),
                ),
              if (isReplyActive)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: TextField(
                    controller: replyController,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.grey[300],
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Write a reply...",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          CommentUtils.submitReply(
                              commentId, ref, replyController, postId);
                          replyController.clear();
                          FocusScope.of(context)
                              .unfocus(); // Optionally close the keyboard
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
      error: (e, st) => const Text('Opps :('),
    );
  }
}
