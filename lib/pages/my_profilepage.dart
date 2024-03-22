import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/user_profile.dart';
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
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No posts found'));
              }
              final posts = snapshot.data!.docs;
              return CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: _buildProfileHeader(
                        context, user, posts.length), // Include post count
                  ),
                  _buildPostsGrid(context, posts), // Pass the posts directly
                ],
              );
            },
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user, int postCount) {
    final usersRef = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: usersRef.doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;

        int followersCount = userData['followers']?.length ?? 0;
        int followingCount = userData['following']?.length ?? 0;
        List<String> followers = List<String>.from(userData['followers'] ?? []);
        List<String> following = List<String>.from(userData['following'] ?? []);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                    user.photoURL ?? 'https://via.placeholder.com/150'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(user.displayName ?? 'Username',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileStat(context, "Posts", postCount, [], ""),
                  _buildProfileStat(context, "Followers", followersCount,
                      followers, "Followers"),
                  _buildProfileStat(context, "Following", followingCount,
                      following, "Followers"),
                ],
              ),
            ],
          ),
        );
      },
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
          SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(
      BuildContext context, List<QueryDocumentSnapshot> posts) {
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

      try {
        await storage.ref(filePath).delete();
      } catch (error) {}
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
    context: context,
    builder: (BuildContext context) {
      return Column(
        children: [
          AppBar(
            title: Text(title),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
