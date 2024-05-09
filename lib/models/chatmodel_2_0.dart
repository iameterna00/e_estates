import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isSeen;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isSeen,
  });

  factory Message.fromFirestore(Map<String, dynamic> firestoreDoc) {
    return Message(
      id: firestoreDoc['id'] as String,
      senderId: firestoreDoc['senderId'] as String,
      text: firestoreDoc['text'] as String,
      timestamp: (firestoreDoc['timestamp'] as Timestamp).toDate(),
      isSeen: firestoreDoc['isSeen'] as bool,
    );
  }

  // Converts the Message object to a JSON format to upload to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSeen': isSeen,
    };
  }
}
