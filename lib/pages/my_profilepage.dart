import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/user_profile.dart';
import 'package:e_estates/stateManagement/Myprofile_provider.dart';
import 'package:e_estates/stateManagement/auth_state_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyProfilePage extends ConsumerWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Profile"),
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Please log in."));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('image')
                .where('UID', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center();
              }

              final posts = snapshot.data!.docs;
              return RefreshIndicator(
                onRefresh: () => refreshUserData(ref, user.uid),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _buildProfileHeader(
                          context, ref, user.uid, posts.length),
                    ),
                    _buildPostsGrid(context, posts),
                  ],
                ),
              );
            },
          );
        },
        loading: () => Container(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, WidgetRef ref, String userId, int postCount) {
    final userProfileAsyncValue = ref.watch(userProfileProvider(userId));

    return userProfileAsyncValue.when(
      data: (userProfile) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(userProfile.photoUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(userProfile.username,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Ensure postCount and the lists are passed correctly
                _buildProfileStat(context, "Posts", postCount, [], "Posts"),
                _buildProfileStat(
                  context,
                  "Followers",
                  userProfile.followers.length,
                  userProfile.followers.cast<String>(),
                  "Followers",
                ),
                _buildProfileStat(
                  context,
                  "Following",
                  userProfile.following.length,
                  userProfile.following.cast<String>(),
                  "Following",
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildProfileStat(BuildContext context, String label, int count,
      List<String> userIds, String title) {
    return InkWell(
      onTap: () => _showUserList(context, userIds, title),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$count', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(
      BuildContext context, List<QueryDocumentSnapshot> posts) {
    if (posts.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No posts found')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(4),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = posts[index];
            List<dynamic> imageUrls = post.get('urls');
            return GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Post"),
                  content: Image.network(imageUrls.first, fit: BoxFit.cover),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                    if (post.get('UID') ==
                        FirebaseAuth.instance.currentUser
                            ?.uid) // Check if current user is the post owner
                      TextButton(
                        onPressed: () => _deletePost(context, post.id),
                        child: const Text("Delete"),
                      ),
                  ],
                ),
              ),
              child: Image.network(imageUrls.first, fit: BoxFit.cover),
            );
          },
          childCount: posts.length,
        ),
      ),
    );
  }

  Future<void> _deletePost(BuildContext context, String postId) async {
    DocumentSnapshot postDocument =
        await FirebaseFirestore.instance.collection('image').doc(postId).get();

    List<dynamic> imageUrls = postDocument.get('urls') as List<dynamic>;

    FirebaseStorage storage = FirebaseStorage.instance;

    for (String url in imageUrls) {
      String filePath = url.replaceAll(
          RegExp(
              r'https://firebasestorage.googleapis.com/v0/b/[a-z0-9-]+.appspot.com/o/'),
          '');
      filePath = Uri.decodeFull(filePath.split('?').first);

      await storage.ref(filePath).delete();
    }

    FirebaseFirestore.instance
        .collection('image')
        .doc(postId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post deleted successfully.")));

      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting post: $error")));
    });
  }
}

void _showUserList(BuildContext context, List<String> userIds, String title) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white,
    context: context,
    builder: (BuildContext context) {
      return Column(
        children: [
          IconButton(
            icon: const Icon(Icons.drag_handle_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppBar(
            title: Text(title),
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userIds.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userIds[index])
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
                        leading: CircleAvatar(),
                        title: Text("Loading..."),
                      );
                    }
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    UserModel userModel = UserModel.fromMap(userData);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(userData['profileUrl'] ??
                            'https://via.placeholder.com/150'),
                      ),
                      title: Text(userData['username'] ?? 'Username'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              UserProfilePage(user: userModel),
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
