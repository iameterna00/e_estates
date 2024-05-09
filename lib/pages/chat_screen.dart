import 'package:e_estates/models/chat_model.dart';
import 'package:e_estates/models/conversation_model.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final ChatModel chatDetails;
  final String otherUserProfile;
  final String otherUsername;

  const ChatScreen(
      {super.key,
      required this.currentUserId,
      required this.chatDetails,
      required this.otherUserProfile,
      required this.otherUsername});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        markChatAsSeen();
      }
    });
  }

  void sendMessage() async {
    final String content = _messageController.text.trim();
    if (content.isNotEmpty) {
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: widget.currentUserId,
        receiverId: widget.chatDetails.participantIds
            .firstWhere((id) => id != widget.currentUserId),
        content: content,
        timestamp: DateTime.now(),
      );
      _messageController.clear();
      CollectionReference messages = FirebaseFirestore.instance
          .collection('chats/${widget.chatDetails.id}/messages');

      await messages.add(message.toJson());

      DocumentReference chatDoc = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatDetails.id);

      await chatDoc.update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'hasUnseenMessages': true
      });
    }
  }

  Stream<List<MessageModel>> fetchMessages() {
    return FirebaseFirestore.instance
        .collection('chats/${widget.chatDetails.id}/messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(
              widget.otherUserProfile,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(widget.otherUsername)
        ],
      )),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: fetchMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                markChatAsSeen();
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isSentByMe = message.senderId == widget.currentUserId;

                    return Row(
                      mainAxisAlignment: isSentByMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSentByMe) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.otherUserProfile),
                              radius: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: isSentByMe
                                ? Colors.blue
                                : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.grey[400],
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isSentByMe
                                  ? Colors.white
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: _messageController,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.grey[300],
                      hintText: "Write a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void markChatAsSeen() async {
    final lastMessageSnapshot = await FirebaseFirestore.instance
        .collection('chats/${widget.chatDetails.id}/messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (lastMessageSnapshot.docs.isNotEmpty) {
      final lastMessageSenderId =
          lastMessageSnapshot.docs.first.data()['senderId'];

      if (lastMessageSenderId != widget.currentUserId) {
        DocumentReference chatDoc = FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatDetails.id);

        chatDoc.update({'hasUnseenMessages': false});
      }
    }
  }
}
