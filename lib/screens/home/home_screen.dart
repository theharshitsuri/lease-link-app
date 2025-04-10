import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/listing_card.dart';
import 'listing_detail_screen.dart';
import '../chat/chat_list_screen.dart'; // 👈 Import the ChatListScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _listingsFuture = fetchListings();
  }

  Future<List<Map<String, dynamic>>> fetchListings() async {
    final response = await supabase
        .from('listings')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> toggleFavorite(String listingId, bool newValue) async {
    await supabase
        .from('listings')
        .update({'is_favorite': newValue})
        .eq('id', listingId);

    setState(() {
      _listingsFuture = fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            tooltip: 'Chats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _listingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No listings found.', style: TextStyle(color: Colors.white)));
          }

          final listings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final images = listing['images'] ?? [];
              final isFavorite = listing['is_favorite'] ?? false;
              final listingId = listing['id'];
              final userId = listing['user_id'];
              final userEmail = listing['user_email'] ?? '';

              return ListingCard(
                title: listing['title'] ?? '',
                location: listing['location'] ?? '',
                rent: listing['rent']?.toString() ?? '',
                availableFrom: listing['available_from'] ?? '',
                images: images,
                isFavorite: isFavorite,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(
                        id: listingId,
                        title: listing['title'] ?? '',
                        location: listing['location'] ?? '',
                        rent: listing['rent']?.toString() ?? '',
                        availableFrom: listing['available_from'] ?? '',
                        description: listing['description'] ?? '',
                        gender: listing['gender'] ?? '',
                        images: images,
                        userId: userId,
                        userEmail: userEmail,
                      ),
                    ),
                  );
                },
                onFavoriteToggle: () {
                  toggleFavorite(listingId, !isFavorite);
                },
              );
            },
          );
        },
      ),
    );
  }
}
