import 'package:e_estates/models/chat_model.dart';
import 'package:e_estates/models/conversation_model.dart';
import 'package:e_estates/service/chat_functions.dart';
import 'package:flutter/material.dart';

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
        ChatUtils.markChatAsSeen(widget.chatDetails.id, widget.currentUserId);
      }
    });
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
              stream: ChatUtils.fetchMessages(widget.chatDetails.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                ChatUtils.markChatAsSeen(
                    widget.chatDetails.id, widget.currentUserId);
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
                        Flexible(
                          child: Container(
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
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      ChatUtils.sendMessage(
                          _messageController,
                          widget.currentUserId,
                          widget.chatDetails.participantIds,
                          widget.chatDetails.id);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
