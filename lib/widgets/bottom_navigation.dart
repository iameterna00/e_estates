import 'package:e_estates/pages/chat_lists.dart';
import 'package:e_estates/pages/discover_page.dart';
import 'package:e_estates/pages/home_screen.dart';
import 'package:e_estates/stateManagement/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomAppBar extends ConsumerWidget {
  final VoidCallback onExplore;
  final VoidCallback onFavorites;
  final VoidCallback onAdd;
  final VoidCallback onChat;
  final VoidCallback? onProfileTap;

  const CustomBottomAppBar({
    super.key,
    required this.onExplore,
    required this.onFavorites,
    required this.onAdd,
    required this.onChat,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final photoUrl = ref.watch(userProvider)?.photoUrl;
    final userid = ref.watch(userProvider)?.uid;

    return BottomAppBar(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.home, size: 25),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }),
          IconButton(
            icon: const Icon(Icons.explore_rounded, size: 25),
            onPressed: onExplore,
          ),
          IconButton(
            icon: const Icon(Icons.add_box_rounded, size: 25),
            onPressed: onAdd,
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 25),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersListPage(
                    curentUserid: userid,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_rounded, size: 25),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProviderScope(
                  child: ChatAndFollowersPage(
                    userID: userid,
                  ),
                ),
              ));
            },
          ),
          /*     Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: InkWell(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 15,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/icons/noProfile.png')
                        as ImageProvider,
              ),
            ),
          ), */
        ],
      ),
    );
  }
}
