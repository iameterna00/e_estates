import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/profile_edit.dart';
import 'package:e_estates/pages/user_profile.dart';
import 'package:e_estates/service/profile_functions.dart';
import 'package:e_estates/stateManagement/Myprofile_provider.dart';
import 'package:e_estates/stateManagement/auth_state_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Profile"),
            userAsyncValue.when(
              data: (user) {
                if (user == null) {
                  return Container();
                }
                final userprofileAsyncValue =
                    ref.watch(userProfileProvider(user.uid));
                return userprofileAsyncValue.when(
                  data: (userProfile) {
                    return IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileEdit(
                                      userName: userProfile.username,
                                      getCurrentUserProfile:
                                          userProfile.photoUrl!,
                                      number: userProfile.number,
                                      iAm: userProfile.iAm)));
                        },
                        icon: const Icon(Icons.edit));
                  },
                  loading: () => Container(),
                  error: (error, stack) => Container(),
                );
              },
              loading: () => Container(),
              error: (error, stack) => Container(),
            )
          ],
        ),
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
      data: (userProfile) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: userProfile.photoUrl != null &&
                        userProfile.photoUrl!.isNotEmpty
                    ? NetworkImage(userProfile.photoUrl!)
                    : null,
                child: userProfile.photoUrl == null ||
                        userProfile.photoUrl!.isEmpty
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(userProfile.username,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('$postCount',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      const Text('Posts'),
                    ],
                  ),
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
        );
      },
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
                        onPressed: () =>
                            PostFunctions.deletePost(context, post.id),
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
}

void _showUserList(BuildContext context, List<String> userIds, String title) {
  showModalBottomSheet(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      context: context,
      isScrollControlled: true, // Ensure the sheet takes full height if needed
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            //  List<String> filteredUserIds = List.from(userIds);

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.90,
              minChildSize: 0.5,
              maxChildSize: 0.90,
              builder: (context, scrollController) {
                return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 50.0,
                            child: Center(
                              child: Icon(
                                Icons.drag_handle,
                                color: Color.fromARGB(255, 124, 124, 124),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: TextField(
                              style: Theme.of(context).textTheme.bodyMedium,
                              // controller: searchController,
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                fillColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.grey[300],
                                filled: true,
                                hintText: 'Search',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: const Icon(Icons.search),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 20),
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
                                    var userData = snapshot.data!.data()
                                        as Map<String, dynamic>;
                                    UserModel userModel =
                                        UserModel.fromMap(userData);
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(userData[
                                                'profileUrl'] ??
                                            'https://via.placeholder.com/150'),
                                      ),
                                      title: Text(
                                          userData['username'] ?? 'Username'),
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
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
                        ]));
              },
            );
          },
        );
      });
}
