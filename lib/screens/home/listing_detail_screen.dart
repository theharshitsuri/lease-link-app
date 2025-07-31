import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_listing_screen.dart';
import '../chat/chat_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String location;
  final String rent;
  final String availableFrom;
  final String availableTo;
  final String description;
  final String gender;
  final List<dynamic> images;
  final String? userId;
  final String? userEmail;

  const ListingDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.location,
    required this.rent,
    required this.availableFrom,
    required this.availableTo,
    required this.description,
    required this.gender,
    required this.images,
    this.userId,
    this.userEmail,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImageIndex = 0;

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % widget.images.length;
    });
  }

  void _prevImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + widget.images.length) % widget.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final currentUserId = currentUser?.id;
    final currentUserEmail = currentUser?.email;
    final isMyListing = currentUserId == widget.userId;
    final isWeb = MediaQuery.of(context).size.width > 700;

    final imageWidget = widget.images.isEmpty
        ? Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 50, color: Colors.white30),
                  SizedBox(height: 8),
                  Text("No photos available", style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.images[_currentImageIndex],
                  height: isWeb ? 400 : 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (widget.images.length > 1)
                Positioned(
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _prevImage,
                  ),
                ),
              if (widget.images.length > 1)
                Positioned(
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: _nextImage,
                  ),
                ),
            ],
          );

    final detailSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text('${widget.location} · \$${widget.rent}/month', style: const TextStyle(color: Colors.grey)),
        Text('Available from: ${widget.availableFrom}', style: const TextStyle(color: Colors.white70)),
        Text('Available to: ${widget.availableTo}', style: const TextStyle(color: Colors.white70)),
        Text('Gender Preference: ${widget.gender}', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        const Text('Description:',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(widget.description, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 24),
        if (isMyListing)
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditListingScreen(
                          listingId: widget.id,
                          title: widget.title,
                          location: widget.location,
                          rent: widget.rent,
                          availableFrom: widget.availableFrom,
                          availableTo: widget.availableTo,
                          description: widget.description,
                          gender: widget.gender,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Edit', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await supabase.from('listings').delete().eq('id', widget.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Listing deleted')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Delete', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          )
        else
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (currentUserId == null || widget.userId == null || currentUserEmail == null) return;

                final sorted = [currentUserId, widget.userId!]..sort();
                final existingChat = await supabase
                    .from('chats')
                    .select()
                    .eq('user1_id', sorted[0])
                    .eq('user2_id', sorted[1])
                    .maybeSingle();

                String chatId;
                String otherEmail = widget.userEmail ?? 'User';

                if (existingChat != null) {
                  chatId = existingChat['id'];
                  otherEmail = currentUserId == existingChat['user1_id']
                      ? existingChat['user2_email'] ?? otherEmail
                      : existingChat['user1_email'] ?? otherEmail;
                } else {
                  final insert = await supabase.from('chats').insert({
                    'user1_id': sorted[0],
                    'user2_id': sorted[1],
                    'user1_email': sorted[0] == currentUserId ? currentUserEmail : widget.userEmail,
                    'user2_email': sorted[1] == currentUserId ? currentUserEmail : widget.userEmail,
                  }).select();

                  chatId = insert.first['id'];
                }

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chatId,
                        otherUserEmail: otherEmail,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Contact Lister',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Listing Details'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: isWeb
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 400,
                          child: imageWidget,
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 32),
                          child: detailSection,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageWidget,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                      child: detailSection,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}