import 'package:flutter/material.dart';

class ListingCard extends StatefulWidget {
  final String title;
  final String location;
  final String rent;
  final String availableFrom;
  final List<dynamic> images;
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
  void didUpdateWidget(covariant ListingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images != widget.images) {
      _currentImageIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.images.isNotEmpty;
    final currentImage = hasImages ? widget.images[_currentImageIndex].toString() : '';

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
            Stack(
              children: [
                // 📷 Image section
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: hasImages
                        ? DecorationImage(
                            image: NetworkImage(currentImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !hasImages
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 48, color: Colors.white30),
                              SizedBox(height: 8),
                              Text(
                                'No photos available',
                                style: TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),

                // ⬅️ Prev
                if (hasImages && widget.images.length > 1)
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

                // ➡️ Next
                if (hasImages && widget.images.length > 1)
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

                // ❤️ Favorite toggle
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.redAccent : Colors.white70,
                    ),
                    iconSize: 28,
                    onPressed: widget.onFavoriteToggle,
                    splashRadius: 20,
                    tooltip: widget.isFavorite ? 'Remove Favorite' : 'Add to Favorites',
                  ),
                ),
              ],
            ),

            // 📄 Listing Info
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
