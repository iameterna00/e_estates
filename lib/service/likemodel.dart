import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/image_post.dart';
import 'package:e_estates/stateManagement/togglelike.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikeButtonWidget extends ConsumerWidget {
  final String postId;

  const LikeButtonWidget({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(likeStateProvider(postId));
    final notifier = ref.read(likeStateProvider(postId).notifier);

    return InkWell(
      onTap: () {
        notifier.toggleLike();
      },
      child: Row(
        children: [
          Icon(
            likeState.isLiked ? Icons.favorite : Icons.favorite_border,
            color: likeState.isLiked ? Colors.red : Colors.grey,
            size: 25,
          ),
          SizedBox(width: 8),
          Text(
            '${likeState.likeCount} likes',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
