import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserEmail;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final RealtimeChannel _channel;
  List<Map<String, dynamic>> _messages = [];
  Set<int> _showTimestamps = {};

  @override
  void initState() {
    super.initState();
    fetchMessages();
    _subscribeToMessages();
    markMessagesAsRead();
  }

  Future<void> fetchMessages() async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('chat_id', widget.chatId)
        .order('timestamp');

    setState(() {
      _messages = List<Map<String, dynamic>>.from(response);
      _messages.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
    });

    _scrollToBottom();
  }

  Future<void> markMessagesAsRead() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    await supabase.from('messages')
      .update({'read': true})
      .eq('chat_id', widget.chatId)
      .neq('sender_id', currentUserId)
      .eq('read', false);
  }

  void _subscribeToMessages() {
    _channel = supabase.channel('messages:${widget.chatId}');
    _channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'messages',
        filter: 'chat_id=eq.${widget.chatId}',
      ),
      (payload, [ref]) {
        if (payload['new'] != null) {
          setState(() {
            _messages.insert(0, payload['new']);
          });
          _scrollToBottom();
        }
      },
    ).subscribe();
  }

  Future<void> _sendMessage(String text) async {
    final senderId = supabase.auth.currentUser?.id;
    if (senderId == null || text.trim().isEmpty) return;

    await supabase.from('messages').insert({
      'chat_id': widget.chatId,
      'sender_id': senderId,
      'content': text.trim(),
      'read': false,
    });

    _controller.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(String timestamp) {
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return '';
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    supabase.removeChannel(_channel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.otherUserEmail, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.black,
        elevation: 0.5,
        surfaceTintColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMine = msg['sender_id'] == currentUserId;
                  final isVisible = _showTimestamps.contains(index);
                  final time = _formatTimestamp(msg['timestamp']);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _showTimestamps.contains(index)
                            ? _showTimestamps.remove(index)
                            : _showTimestamps.add(index);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment:
                            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMine ? Colors.purple.shade600 : Colors.grey.shade800,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: Radius.circular(isMine ? 14 : 0),
                                bottomRight: Radius.circular(isMine ? 0 : 14),
                              ),
                            ),
                            child: Text(
                              msg['content'],
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                          if (isVisible)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white38,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[850],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
