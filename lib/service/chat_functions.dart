import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/chat_model.dart';
import 'package:e_estates/models/conversation_model.dart';
import 'package:flutter/material.dart';

class ChatUtils {
  static Future<ChatModel> fetchOrCreateChatSession(
      String currentUserId, String followerId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: currentUserId)
        .get();

    QueryDocumentSnapshot<Map<String, dynamic>>? chatDoc;

    for (var doc in querySnapshot.docs) {
      if (doc.data()['participantIds'].contains(followerId)) {
        chatDoc = doc;
        break;
      }
    }

    if (chatDoc != null) {
      return ChatModel.fromMap(chatDoc.data(), chatDoc.id);
    } else {
      // Create a new chat session
      DocumentReference chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc();

      ChatModel newChat = ChatModel(
          id: chatDocRef.id,
          participantIds: [currentUserId, followerId],
          lastMessage: "",
          lastMessageTime: DateTime.now(),
          justSentMessageBy: currentUserId);

      await chatDocRef.set(newChat.toJson());
      return newChat;
    }
  }

  static void markChatAsSeen(String chatDetails, String currentUserId) async {
    final lastMessageSnapshot = await FirebaseFirestore.instance
        .collection('chats/$chatDetails/messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (lastMessageSnapshot.docs.isNotEmpty) {
      final lastMessageSenderId =
          lastMessageSnapshot.docs.first.data()['senderId'];

      if (lastMessageSenderId != currentUserId) {
        DocumentReference chatDoc =
            FirebaseFirestore.instance.collection('chats').doc(chatDetails);

        chatDoc.update({'justSentMessageBy': currentUserId});
      }
    }
  }

  static Stream<List<MessageModel>> fetchMessages(String chatdetails) {
    return FirebaseFirestore.instance
        .collection('chats/$chatdetails/messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  static void sendMessage(
    TextEditingController messageController,
    String currentUserId,
    List<String> chatDetailsParticipants,
    String chatDetailsId,
  ) async {
    final String content = messageController.text.trim();
    if (content.isNotEmpty) {
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        receiverId:
            chatDetailsParticipants.firstWhere((id) => id != currentUserId),
        content: content,
        timestamp: DateTime.now(),
      );
      messageController.clear();
      CollectionReference messages = FirebaseFirestore.instance
          .collection('chats/$chatDetailsId/messages');

      await messages.add(message.toJson());

      DocumentReference chatDoc =
          FirebaseFirestore.instance.collection('chats').doc(chatDetailsId);

      await chatDoc.update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        "justSentMessageBy": currentUserId
      });
    }
  }
}
