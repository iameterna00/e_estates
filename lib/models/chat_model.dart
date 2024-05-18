import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String justSentMessageBy;

  ChatModel(
      {required this.id,
      required this.participantIds,
      required this.lastMessage,
      required this.lastMessageTime,
      required this.justSentMessageBy});

  Map<String, dynamic> toJson() => {
        'participantIds': participantIds,
        'lastMessage': lastMessage,
        'lastMessageTime': Timestamp.fromDate(lastMessageTime),
        'justSentMessageBy': justSentMessageBy
      };

  static ChatModel fromMap(Map<String, dynamic> map, String documentId) {
    return ChatModel(
      id: documentId,
      participantIds: List<String>.from(map['participantIds']),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      justSentMessageBy: map['justSentMessageBy'] ?? '',
    );
  }

  static ChatModel fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    var data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds']),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      justSentMessageBy: data['justSentMessageBy'] ?? "",
    );
  }
}
