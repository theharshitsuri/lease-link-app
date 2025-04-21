import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/listing_card.dart';
import '../home/listing_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _favoritesFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _favoritesFuture = fetchFavorites();
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return [];

    final favoriteIds = await supabase
        .from('favorites')
        .select('listing_id')
        .eq('user_id', currentUser.id);

    final ids = favoriteIds.map((fav) => fav['listing_id']).toList();
    if (ids.isEmpty) return [];

    final listings = await supabase.from('listings').select().in_('id', ids);
    return List<Map<String, dynamic>>.from(listings);
  }

  Future<void> toggleFavorite(String listingId) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', currentUser.id)
        .eq('listing_id', listingId);

    setState(() {
      _favoritesFuture = fetchFavorites();
    });
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final listingId = listing['id'];
    final images = (listing['images'] ?? []) as List<dynamic>;

    return ListingCard(
      title: listing['title'] ?? '',
      location: listing['location'] ?? '',
      rent: listing['rent']?.toString() ?? '',
      availableFrom: listing['available_from'] ?? '',
      images: images,
      isFavorite: true,
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
              userId: listing['user_id'],
              userEmail: listing['user_email'] ?? '',
            ),
          ),
        );
      },
      onFavoriteToggle: () => toggleFavorite(listingId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Saved Listings'),
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.black,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _favoritesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.purple));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No favorites yet.', style: TextStyle(color: Colors.white)));
              }

              final listings = snapshot.data!;

              return isWideScreen
                  ? GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 4 / 3,
                      ),
                      itemCount: listings.length,
                      itemBuilder: (_, index) => _buildListingCard(listings[index]),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: listings.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildListingCard(listings[index]),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
