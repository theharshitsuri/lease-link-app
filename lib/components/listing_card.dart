import 'package:flutter/material.dart';

class ListingCard extends StatefulWidget {
  final String title;
  final String location;
  final String rent;
  final String availableFrom;
  final List<dynamic> images; // ⬅️ Supabase text[]
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const ListingCard({
    super.key,
    required this.title,
    required this.location,
    required this.rent,
    required this.availableFrom,
    required this.images,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  int _currentImageIndex = 0;

  void _nextImage() {
    if (_currentImageIndex < widget.images.length - 1) {
      setState(() => _currentImageIndex++);
    }
  }

  void _prevImage() {
    if (_currentImageIndex > 0) {
      setState(() => _currentImageIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = widget.images.isNotEmpty
        ? widget.images[_currentImageIndex].toString()
        : '';

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image with Arrows and Heart
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: currentImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(currentImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: currentImage.isEmpty
                      ? const Center(child: Icon(Icons.image, size: 60, color: Colors.white30))
                      : null,
                ),
                if (widget.images.length > 1)
                  Positioned(
                    left: 8,
                    top: 75,
                    child: IconButton(
                      onPressed: _prevImage,
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      iconSize: 32,
                      splashRadius: 24,
                    ),
                  ),
                if (widget.images.length > 1)
                  Positioned(
                    right: 8,
                    top: 75,
                    child: IconButton(
                      onPressed: _nextImage,
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      iconSize: 32,
                      splashRadius: 24,
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: widget.onFavoriteToggle,
                    child: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.redAccent : Colors.white70,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),

            // 📝 Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    '\$${widget.rent}/month · Available from ${widget.availableFrom}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
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
