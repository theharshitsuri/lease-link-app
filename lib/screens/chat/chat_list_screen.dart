import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _chatFuture;
  Map<String, int> _unreadCounts = {};
  Map<String, Map<String, dynamic>> _userProfiles = {};

  @override
  void initState() {
    super.initState();
    _chatFuture = fetchChats();
  }

  Future<List<Map<String, dynamic>>> fetchChats() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return [];

    final response = await supabase
        .from('chats')
        .select()
        .or('user1_id.eq.${currentUser.id},user2_id.eq.${currentUser.id}')
        .order('updated_at', ascending: false);

    final chats = List<Map<String, dynamic>>.from(response);

    // Get unread message counts
    final unreadResponse = await supabase
        .from('messages')
        .select()
        .eq('read', false)
        .neq('sender_id', currentUser.id);

    final unreadMessages = List<Map<String, dynamic>>.from(unreadResponse);
    final unreadCountMap = <String, int>{};

    for (var msg in unreadMessages) {
      final chatId = msg['chat_id'];
      unreadCountMap[chatId] = (unreadCountMap[chatId] ?? 0) + 1;
    }

    // Get profile info of chat partners
    for (var chat in chats) {
      final otherUserId = chat['user1_id'] == currentUser.id
          ? chat['user2_id']
          : chat['user1_id'];

      if (!_userProfiles.containsKey(otherUserId)) {
        final profileResponse = await supabase
            .from('profiles')
            .select()
            .eq('id', otherUserId)
            .maybeSingle();

        if (profileResponse != null) {
          _userProfiles[otherUserId] = profileResponse;
        }
      }
    }

    setState(() {
      _unreadCounts = unreadCountMap;
    });

    return chats;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>> (
        future: _chatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chats found.', style: TextStyle(color: Colors.white)));
          }

          final chats = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: chats.length,
            separatorBuilder: (_, __) => Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat['user1_id'] == currentUserId
                  ? chat['user2_id']
                  : chat['user1_id'];
              final otherProfile = _userProfiles[otherUserId];
              final otherName = otherProfile?['name'] ?? 'User';
              final profileImage = otherProfile?['profile_image_url'];
              final chatId = chat['id'];
              final unreadCount = _unreadCounts[chatId] ?? 0;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.purple,
                      backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
                      child: profileImage == null
                          ? Text(
                              otherName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      )
                  ],
                ),
                title: Text(
                  otherName,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () async {
                  await supabase
                      .from('messages')
                      .update({'read': true})
                      .eq('chat_id', chatId)
                      .neq('sender_id', currentUserId);

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chatId,
                        otherUserEmail: otherProfile?['name'] ?? 'User',
                      ),
                    ),
                  );

                  setState(() {
                    _chatFuture = fetchChats();
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
