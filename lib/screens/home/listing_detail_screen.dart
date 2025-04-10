import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_listing_screen.dart';
import '../chat/chat_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  final String id;
  final String title;
  final String location;
  final String rent;
  final String availableFrom;
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
    required this.description,
    required this.gender,
    required this.images,
    this.userId,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final currentUserId = currentUser?.id;
    final currentUserEmail = currentUser?.email;
    final isMyListing = currentUserId == userId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Listing Details'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imgUrl = images[index].toString();
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imgUrl,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image, color: Colors.white30, size: 60)),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.image, color: Colors.grey, size: 60),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('$location · \$$rent/month', style: const TextStyle(color: Colors.grey)),
                  Text('Available from: $availableFrom', style: const TextStyle(color: Colors.white70)),
                  Text('Gender Preference: $gender', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  const Text('Description:',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 24),

                  if (isMyListing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditListingScreen(
                                  listingId: id,
                                  title: title,
                                  location: location,
                                  rent: rent,
                                  availableFrom: availableFrom,
                                  description: description,
                                  gender: gender,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text('Edit', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await supabase.from('listings').delete().eq('id', id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Listing deleted')),
                              );
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text('Delete', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (currentUserId == null || userId == null || currentUserEmail == null) return;

                          final sorted = [currentUserId, userId!]..sort();
                          final existingChat = await supabase
                              .from('chats')
                              .select()
                              .eq('user1_id', sorted[0])
                              .eq('user2_id', sorted[1])
                              .maybeSingle();

                          String chatId;
                          String otherEmail = userEmail ?? 'User';

                          if (existingChat != null) {
                            chatId = existingChat['id'];
                            // Get the other user's email from the row if available
                            otherEmail = currentUserId == existingChat['user1_id']
                                ? existingChat['user2_email'] ?? otherEmail
                                : existingChat['user1_email'] ?? otherEmail;
                          } else {
                            final insert = await supabase.from('chats').insert({
                              'user1_id': sorted[0],
                              'user2_id': sorted[1],
                              'user1_email': sorted[0] == currentUserId ? currentUserEmail : userEmail,
                              'user2_email': sorted[1] == currentUserId ? currentUserEmail : userEmail,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
