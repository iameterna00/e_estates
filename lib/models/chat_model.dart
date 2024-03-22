import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String messageContent;
  final Timestamp timestamp;
  final bool isSeen;
  final List<String> participants; // Add this line

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.messageContent,
    required this.timestamp,
    required this.isSeen,
    required this.participants, // Add this
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'messageContent': messageContent,
        'timestamp': timestamp,
        'isSeen': isSeen,
        'participants': participants, // Add this
      };

  static ChatMessage fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return ChatMessage(
      messageId: snapshot['messageId'] ?? '',
      senderId: snapshot['senderId'] ?? '',
      receiverId: snapshot['receiverId'] ?? '',
      messageContent: snapshot['messageContent'] ?? '',
      timestamp: snapshot['timestamp'],
      isSeen: snapshot['isSeen'] ?? false,
      participants: List<String>.from(snapshot['participants']), // Add this
    );
  }
}
