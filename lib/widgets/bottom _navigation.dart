import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomBottomAppBar extends StatefulWidget {
  final FirebaseAuth auth;
  final VoidCallback onExplore;
  final VoidCallback onFavorites;
  final VoidCallback onAdd;
  final VoidCallback onChat;
  final VoidCallback onProfileTap;

  const CustomBottomAppBar({
    super.key,
    required this.auth,
    required this.onExplore,
    required this.onFavorites,
    required this.onAdd,
    required this.onChat,
    required this.onProfileTap,
  });

  @override
  State<CustomBottomAppBar> createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  String? photoUrl;

  Future<void> _reloadUser() async {
    await widget.auth.currentUser?.reload();
    photoUrl = widget.auth.currentUser?.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.1))),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: BottomAppBar(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.explore_outlined, size: 30),
                onPressed: widget.onExplore,
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 30),
                onPressed: widget.onFavorites,
              ),
              IconButton(
                icon: const Icon(Icons.add_box_outlined, size: 30),
                onPressed: widget.onAdd,
              ),
              IconButton(
                icon: const Icon(Icons.chat_outlined, size: 30),
                onPressed: widget.onChat,
              ),
              InkWell(
                onTap: widget.onProfileTap,
                child: FutureBuilder(
                    future: _reloadUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CircleAvatar(
                          radius: 15,
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl!)
                              : const AssetImage(
                                      'path/to/your/default/image.png')
                                  as ImageProvider,
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
