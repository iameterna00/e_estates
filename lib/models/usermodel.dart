import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final List followers;
  final List following;

  UserModel({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'profileUrl': photoUrl,
        "followers": followers,
        'following': following
      };
  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['profileUrl'] ?? 'https://via.placeholder.com/150',
      followers: map['followers'] ?? [],
      following: map['following'] ?? [],
    );
  }

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      username: snapshot['username'] ?? '', // Provide a default empty string
      uid: snapshot['uid'] ?? '', // Provide a default empty string
      email: snapshot['email'] ?? '', // Provide a default empty string
      photoUrl: snapshot['profileUrl'] ??
          'https://via.placeholder.com/150', // Provide a default placeholder URL
      followers: snapshot['followers'] ?? [],
      following: snapshot['following'] ?? [],
    );
  }

  static fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}
