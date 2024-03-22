import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/my_profilepage.dart';
import 'package:e_estates/pages/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListPage extends StatefulWidget {
  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Search for users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
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
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                List<UserModel> users = snapshot.data!.docs.map((doc) {
                  return UserModel.fromSnap(doc);
                }).toList();

                List<UserModel> filteredUsers = users.where((user) {
                  String username = user.username.toLowerCase();
                  String useremail = user.email.toLowerCase();
                  return username.contains(searchQuery) ||
                      useremail.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var user = filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      title: Text(user.username),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UserProfilePage(
                                  user: user,
                                )));
                      },
                      // Optionally, add follow functionality here
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
