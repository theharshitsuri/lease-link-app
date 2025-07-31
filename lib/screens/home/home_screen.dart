import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/listing_card.dart';
import '../home/listing_detail_screen.dart';
import '../chat/chat_list_screen.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late ScrollController _scrollController;
  double? _selectedLat;
  double? _selectedLng;
  List<Map<String, dynamic>> _currentListings = [];
  late Future<List<Map<String, dynamic>>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _listingsFuture = fetchListings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<List<Map<String, dynamic>>> fetchListings() async {
    final currentUser = supabase.auth.currentUser;
    final response = await supabase.from('listings').select();
    final listings = List<Map<String, dynamic>>.from(response);

    if (currentUser != null) {
      final favs = await supabase
          .from('favorites')
          .select('listing_id')
          .eq('user_id', currentUser.id);

      final favoriteIds = favs.map((f) => f['listing_id']).toSet();
      for (var listing in listings) {
        listing['is_favorite'] = favoriteIds.contains(listing['id']);
      }
    }

    if (_selectedLat != null && _selectedLng != null) {
      for (var listing in listings) {
        final lat = listing['latitude'];
        final lng = listing['longitude'];
        listing['distance'] = (lat != null && lng != null)
            ? _calculateDistance(_selectedLat!, _selectedLng!, lat, lng)
            : double.infinity;
      }
      listings.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    }

    _currentListings = listings;
    return listings;
  }

  Future<void> toggleFavorite(String listingId, bool isCurrentlyFavorite) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    if (isCurrentlyFavorite) {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
    } else {
      await supabase.from('favorites').insert({
        'user_id': userId,
        'listing_id': listingId,
      });
    }

    final index = _currentListings.indexWhere((l) => l['id'] == listingId);
    if (index != -1) {
      setState(() {
        _currentListings[index]['is_favorite'] = !isCurrentlyFavorite;
      });
    }
  }

  void _onLocationSelected(Prediction prediction) {
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();
    setState(() {
      _searchController.text = prediction.description ?? '';
      _selectedLat = double.tryParse(prediction.lat ?? '');
      _selectedLng = double.tryParse(prediction.lng ?? '');
      _listingsFuture = fetchListings();
    });
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color.fromARGB(255, 0, 0, 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.purple),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
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
              availableTo: listing['available_to'],
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
        toggleFavorite(listingId, isFavorite);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Explore', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.black,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.house_rounded, size: 36, color: Colors.purple),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            tooltip: 'Chats',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
            },
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: _searchController,
                    focusNode: _searchFocusNode,
                    googleAPIKey: "AIzaSyAhxj35WP_-sm_0C23hcQNYS5BqmNl09Cw",
                    inputDecoration: _inputDecoration('Search by city or address...'),
                    debounceTime: 400,
                    isLatLngRequired: true,
                    getPlaceDetailWithLatLng: _onLocationSelected,
                    itemClick: (Prediction p) {
                      _onLocationSelected(p);
                      _searchFocusNode.unfocus();
                    },
                    seperatedBuilder: const Divider(height: 1, color: Colors.grey),
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _listingsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.purple));
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No listings found.', style: TextStyle(color: Colors.white)));
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: isWide
                            ? GridView.builder(
                                itemCount: _currentListings.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 4 / 3,
                                ),
                                itemBuilder: (_, index) => _buildListingCard(_currentListings[index]),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _currentListings.length,
                                itemBuilder: (_, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildListingCard(_currentListings[index]),
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
