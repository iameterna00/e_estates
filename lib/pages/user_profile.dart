import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_estates/models/usermodel.dart'; // Ensure this path matches your UserModel location

class UserProfilePage extends StatefulWidget {
  final UserModel user;

  UserProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  void checkIfFollowing() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        isFollowing = widget.user.followers.contains(currentUser.uid);
      });
    }
  }

  void toggleFollow() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final usersRef = FirebaseFirestore.instance.collection('users');
    if (currentUser == null) return;

    if (isFollowing) {
      // Unfollow User
      await usersRef.doc(currentUser.uid).update({
        'following': FieldValue.arrayRemove([widget.user.uid]),
      });
      await usersRef.doc(widget.user.uid).update({
        'followers': FieldValue.arrayRemove([currentUser.uid]),
      });
    } else {
      // Follow User
      await usersRef.doc(currentUser.uid).update({
        'following': FieldValue.arrayUnion([widget.user.uid]),
      });
      await usersRef.doc(widget.user.uid).update({
        'followers': FieldValue.arrayUnion([currentUser.uid]),
      });
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ElevatedButton(
              onPressed: () => toggleFollow(),
              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            ),
            const SizedBox(height: 20),
            const Text("Posts"),
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
                  return Center(child: Text('No posts found'));
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
                    return Image.network(post['urls'][0], fit: BoxFit.cover);
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
