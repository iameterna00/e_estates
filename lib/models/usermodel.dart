import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String uid;
  final String? photoUrl;
  final String username;
  final List followers;
  final List following;
  final String number;

  UserModel({
    required this.email,
    required this.uid,
    required this.number,
    required this.photoUrl,
    required this.username,
    required this.followers,
    required this.following,
  });

  // Named constructor for an empty user
  UserModel.empty()
      : email = '',
        uid = '',
        photoUrl = 'https://via.placeholder.com/150',
        username = '',
        number = '',
        followers = [],
        following = [];

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'number': number,
        'email': email,
        'profileUrl': photoUrl,
        'followers': followers,
        'following': following
      };

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      number: map['number'] ?? '',
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['profileUrl'] ?? 'https://via.placeholder.com/150',
      followers: map['followers'] ?? [],
      following: map['following'] ?? [],
    );
  }

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return fromMap(snapshot);
  }
}
