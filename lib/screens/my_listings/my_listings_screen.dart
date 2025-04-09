import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/listing_card.dart';
import '../home/listing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _myListingsFuture;

  @override
  void initState() {
    super.initState();
    _myListingsFuture = fetchUserListings();
  }

  Future<List<Map<String, dynamic>>> fetchUserListings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('listings')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> toggleFavorite(String listingId, bool newValue) async {
    await supabase
        .from('listings')
        .update({'is_favorite': newValue})
        .eq('id', listingId);

    setState(() {
      _myListingsFuture = fetchUserListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _myListingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No listings found.',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final listings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final listingId = listing['id'];
              final userId = listing['user_id'];
              final isFavorite = listing['is_favorite'] ?? false;
              final images = (listing['images'] ?? []) as List<dynamic>;

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
                        gender: listing['gender'] ?? 'Any',
                        images: images,
                        userId: userId,
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
