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
        .or('user1_id.eq.${currentUser.id},user2_id.eq.${currentUser.id}');

    return List<Map<String, dynamic>>.from(response);
  }

  String getOtherUserEmail(Map<String, dynamic> chat, String currentUserId) {
    return chat['user1_id'] == currentUserId
        ? chat['user2_email'] ?? 'User'
        : chat['user1_email'] ?? 'User';
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
              final otherEmail = getOtherUserEmail(chat, currentUserId);
              final initial = otherEmail.isNotEmpty ? otherEmail[0].toUpperCase() : '?';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.purple,
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(
                  otherEmail,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chat['id'].toString(),
                        otherUserEmail: otherEmail,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
