import 'package:e_estates/stateManagement/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomAppBar extends ConsumerWidget {
  final VoidCallback onExplore;
  final VoidCallback onFavorites;
  final VoidCallback onAdd;
  final VoidCallback onChat;
  final VoidCallback onProfileTap;

  const CustomBottomAppBar({
    super.key,
    required this.onExplore,
    required this.onFavorites,
    required this.onAdd,
    required this.onChat,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrl = ref.watch(userPhotoURLProvider);

    return BottomAppBar(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.explore_outlined, size: 25),
            onPressed: onExplore,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 25),
            onPressed: onFavorites,
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined, size: 25),
            onPressed: onAdd,
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined, size: 25),
            onPressed: onChat,
          ),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: InkWell(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 15,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : const AssetImage('path/to/your/default/image.png')
                        as ImageProvider,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
