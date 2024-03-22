import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;
  String userProfileUrl;
  String username;

  Comment(
      {required this.id,
      required this.postId,
      required this.userId,
      required this.content,
      required this.timestamp,
      this.userProfileUrl = '',
      required this.username});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Comment(
      id: doc.id,
      postId: doc['postId'],
      userId: doc['userId'],
      content: doc['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(doc['timestamp']),
      userProfileUrl: data['userProfileUrl'] ?? '',
      username: doc['username'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
