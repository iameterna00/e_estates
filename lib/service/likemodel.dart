import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/image_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final likeUpdateProvider =
    StateProvider.family<bool, String>((ref, postId) => false);
Future<bool> toggleLikeStatus(ImagePost post, WidgetRef ref) async {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final DocumentReference postRef = _firestore.collection('image').doc(post.id);

  final bool isLiked = post.likedUsers.contains(currentUserId);

  if (isLiked) {
    await postRef.update({
      'likedUsers': FieldValue.arrayRemove([currentUserId]),
    });

    post.likedUsers.remove(currentUserId);
  } else {
    await postRef.update({
      'likedUsers': FieldValue.arrayUnion([currentUserId]),
    });

    post.likedUsers.add(currentUserId);
  }

  return !isLiked;
}

class LikeButtonWidget extends StatefulWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onLikePressed;

  const LikeButtonWidget({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.onLikePressed,
  });

  @override
  _LikeButtonWidgetState createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
            begin: 1, end: 1.4) // Begin at normal size and scale up to 140%
        .animate(CurvedAnimation(
            parent: _controller,
            curve:
                Curves.elasticOut)); // Use elasticOut curve for a "pop" effect

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller
            .reverse(); // Automatically reverse the animation (scale back down) after reaching the end
      }
    });
  }

  void _handleTap() {
    widget.onLikePressed();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: Row(
        children: [
          AnimatedBuilder(
            // Use an AnimatedBuilder to rebuild the icon with the scale animation
            animation: _controller,
            builder: (context, _) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.isLiked ? Colors.red : Colors.grey,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.likesCount} likes',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
