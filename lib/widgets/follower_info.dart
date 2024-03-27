import 'package:e_estates/models/usermodel.dart';
import 'package:flutter/material.dart';

class FollowersInfoWidget extends StatelessWidget {
  final UserModel user;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  const FollowersInfoWidget({
    Key? key,
    required this.user,
    required this.isFollowing,
    required this.onToggleFollow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Followers: ${user.followers.length}"),
        Text("Following: ${user.following.length}"),
        ElevatedButton(
          onPressed: onToggleFollow,
          child: Text(isFollowing ? 'Unfollow' : 'Follow'),
        ),
      ],
    );
  }
}
