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
    final hasImages = widget.images.isNotEmpty;
    final currentImage = hasImages ? widget.images[_currentImageIndex] : null;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      image: currentImage != null
                          ? DecorationImage(
                              image: NetworkImage(currentImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: currentImage == null
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, color: Colors.white38, size: 40),
                                SizedBox(height: 6),
                                Text("No photos available", style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          )
                        : null,
                  ),

                  // Favorite icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: widget.onFavoriteToggle,
                      child: Icon(
                        widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: widget.isFavorite ? Colors.redAccent : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // Left arrow
                  if (hasImages && widget.images.length > 1)
                    Positioned(
                      left: 8,
                      top: 50,
                      child: GestureDetector(
                        onTap: _prevImage,
                        child: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 16,
                          child: Icon(Icons.chevron_left, color: Colors.white),
                        ),
                      ),
                    ),

                  // Right arrow
                  if (hasImages && widget.images.length > 1)
                    Positioned(
                      right: 8,
                      top: 50,
                      child: GestureDetector(
                        onTap: _nextImage,
                        child: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 16,
                          child: Icon(Icons.chevron_right, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),

              // Info Section
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.location,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.rent}/month · Available from ${widget.availableFrom}',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
