import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/user_profile.dart';
import 'package:e_estates/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListPage extends StatefulWidget {
  final dynamic curentUserid;

  const UsersListPage({super.key, required this.curentUserid});
  @override
  UsersListPageState createState() => UsersListPageState();
}

class UsersListPageState extends State<UsersListPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomAppBar(
        onExplore: () {
          Navigator.pushNamed(context, "/explore");
        },
        onFavorites: () {},
        onAdd: () {
          Navigator.pushNamed(context, "/picker");
        },
        onChat: () {},
      ),
      appBar: AppBar(
        title: const Text('Discover Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey[300],
                hintText: 'Search for users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<UserModel> users = snapshot.data!.docs.map((doc) {
                  return UserModel.fromSnap(doc);
                }).toList();

                List<UserModel> filteredUsers = users.where((user) {
                  return user.uid != widget.curentUserid &&
                      (user.username.toLowerCase().contains(searchQuery) ||
                          user.email.toLowerCase().contains(searchQuery));
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var user = filteredUsers[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UserProfilePage(
                                  user: user,
                                )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                                backgroundImage: user.photoUrl!.isNotEmpty
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: user.photoUrl!.isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.white)
                                    : null),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                user.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
