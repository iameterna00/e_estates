import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/pages/post_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_estates/models/usermodel.dart';

class UserProfilePage extends StatefulWidget {
  final UserModel user;

  const UserProfilePage({super.key, required this.user});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  bool isFollowing = false;
  late ValueNotifier<bool> isFollowingNotifier;

  @override
  void initState() {
    super.initState();
    isFollowingNotifier = ValueNotifier(
        widget.user.followers.contains(FirebaseAuth.instance.currentUser?.uid));
  }

  void toggleFollow() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users');
    if (currentUser == null) return;

    bool newFollowingStatus = !isFollowingNotifier.value;
    isFollowingNotifier.value = newFollowingStatus;

    try {
      if (newFollowingStatus) {
        await userRef.doc(widget.user.uid).update({
          'followers': FieldValue.arrayUnion([currentUser.uid])
        });
        await userRef.doc(currentUser.uid).update({
          'following': FieldValue.arrayUnion([widget.user.uid])
        });
      } else {
        await userRef.doc(widget.user.uid).update({
          'followers': FieldValue.arrayRemove([currentUser.uid])
        });
        await userRef.doc(currentUser.uid).update({
          'following': FieldValue.arrayRemove([widget.user.uid])
        });
      }
    } catch (e) {
      isFollowingNotifier.value = !newFollowingStatus;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occured. Please try again")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      appBar: AppBar(
        title: Text(widget.user.username),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(widget.user.photoUrl),
            ),
            const SizedBox(height: 20),
            Text("Followers: ${widget.user.followers.length}"),
            Text("Following: ${widget.user.following.length}"),
            ValueListenableBuilder<bool>(
              valueListenable: isFollowingNotifier,
              builder: (context, isFollowing, _) {
                return ElevatedButton(
                  onPressed: toggleFollow,
                  child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                );
              },
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Posts"),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('image')
                  .where('UID', isEqualTo: widget.user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox(
                      height: 300,
                      child: Center(
                          child: Text(
                        'No posts found',
                        style: TextStyle(color: Colors.grey),
                      )));
                }
                var posts = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index].data() as Map<String, dynamic>;
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(
                                postData:
                                    posts[index].data() as Map<String, dynamic>,
                                allPosts: posts
                                    .map((doc) =>
                                        doc.data() as Map<String, dynamic>)
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        child:
                            Image.network(post['urls'][0], fit: BoxFit.cover));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
