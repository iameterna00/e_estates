import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/chat_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatsProvider =
    StreamProvider.family<List<ChatModel>, String>((ref, userID) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  return firestore
      .collection('chats')
      .where('participantIds', arrayContains: userID)
      .where('lastMessage', isNotEqualTo: "")
      .orderBy('lastMessage')
      .orderBy('lastMessageTime', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
});
