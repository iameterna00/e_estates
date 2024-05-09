import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;
  String userProfileUrl;
  String username;
  String? parentId; // Optional field to reference the parent comment

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.userProfileUrl = '',
    required this.username,
    this.parentId,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Comment(
      id: doc.id,
      postId: data['postId'] ?? 'default_postId',
      userId: data['userId'] ?? 'default_userId',
      content: data['content'] ?? 'No content provided',
      timestamp: data.containsKey('timestamp')
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : DateTime.now(),
      userProfileUrl: data['userProfileUrl'] ?? '',
      username: data['username'] ?? 'Anonymous',
      parentId: data['parentId'], // Optional, can be null
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'parentId': parentId, // Include the parentId in the Firestore document
    };
  }
}
