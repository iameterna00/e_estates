import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/chat_model.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/chat_screen.dart';
import 'package:e_estates/service/customtime.dart';
import 'package:e_estates/stateManagement/alluser_provider.dart';
import 'package:e_estates/stateManagement/chat_provider.dart';
import 'package:e_estates/stateManagement/followeduser_lists.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatAndFollowersPage extends StatefulWidget {
  final dynamic userID;

  const ChatAndFollowersPage({super.key, required this.userID});
  @override
  State<ChatAndFollowersPage> createState() => _ChatAndFollowersPageState();
}

class _ChatAndFollowersPageState extends State<ChatAndFollowersPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            overlayColor: MaterialStatePropertyAll(Colors.transparent),
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'followed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatsList(
              userID: widget.userID,
            ),
            FollowersList(
              userID: widget.userID,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatsList extends ConsumerWidget {
  final String userID;
  const ChatsList({super.key, required this.userID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsyncValue = ref.watch(chatsProvider(userID));
    final usersAsyncValue = ref.watch(allUsersProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: TextField(
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.grey[300],
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
      Expanded(
        child: usersAsyncValue.when(
          data: (usersMap) => chatsAsyncValue.when(
            data: (chats) {
              final filteredChats = chats.where((chat) {
                final otherUserId =
                    chat.participantIds.firstWhere((id) => id != userID);
                final otherUser = usersMap[otherUserId];
                return otherUser != null &&
                    (otherUser.username
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        otherUser.email
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()));
              }).toList();
              filteredChats.sort(
                  (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

              return ListView.builder(
                itemCount: filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = filteredChats[index];
                  final otherUserId =
                      chat.participantIds.firstWhere((id) => id != userID);
                  final otherUser = usersMap[otherUserId]!;
                  String timeAgo = shortTimeAgo(chat.lastMessageTime);
                  String messageDisplay = chat.lastMessage.isNotEmpty
                      ? "${chat.lastMessage} · $timeAgo"
                      : "You haven't talked yet";
                  return ListTile(
                    leading: CircleAvatar(
                      child: ClipOval(
                        child: Image.network(
                          otherUser.photoUrl,
                          fit: BoxFit.cover,
                          width: 48, // The size of the CircleAvatar
                          height: 48,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const Icon(Icons.person, size: 48);
                            }
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Icon(Icons.error,
                                size: 48); // Fallback icon in case of error
                          },
                        ),
                      ),
                    ),
                    title: Text(otherUser.username),
                    subtitle: Text(messageDisplay),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  currentUserId: userID,
                                  chatDetails: chat,
                                  otherUserProfile: otherUser.photoUrl,
                                  otherUsername: otherUser.username)));
                    },
                    trailing: chat.hasUnseenMessages
                        ? const Icon(Icons.circle, color: Colors.blue, size: 12)
                        : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error fetching chats: $e'),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error fetching users: $e'),
        ),
      ),
    ]);
  }
}

final searchQueryProvider = StateProvider.autoDispose<dynamic>((ref) => '');

class FollowersList extends ConsumerStatefulWidget {
  final dynamic userID;

  const FollowersList({super.key, required this.userID});

  @override
  _FollowersListState createState() => _FollowersListState();
}

class _FollowersListState extends ConsumerState<FollowersList> {
  @override
  Widget build(BuildContext context) {
    final followedUsersStream =
        ref.watch(followedUsersStreamProvider(widget.userID));
    final searchQuery = ref.watch(searchQueryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.grey[300],
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
        Expanded(
          child: followedUsersStream.when(
            data: (List<UserModel> followedUsers) {
              final filteredUsers = followedUsers.where((user) {
                return user.username
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    user.email
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
              }).toList();

              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    onTap: () async {
                      final chatDetails = await fetchOrCreateChatSession(
                          widget.userID, user.uid);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            currentUserId: widget.userID,
                            chatDetails: chatDetails,
                            otherUserProfile: user.photoUrl,
                            otherUsername: user.username,
                          ),
                        ),
                      );
                    },
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
        ),
      ],
    );
  }
}

Future<ChatModel> fetchOrCreateChatSession(
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
      hasUnseenMessages: true,
    );

    await chatDocRef.set(newChat.toJson());
    return newChat;
  }
}
