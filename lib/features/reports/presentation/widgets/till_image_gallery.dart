import 'package:flutter/material.dart';
import '../../../stores/domain/entities/till_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_image.dart'; // Import TillImage

class TillImageGallery extends StatefulWidget {
  final Till till;
  final String storeName;

  const TillImageGallery({
    Key? key,
    required this.till,
    required this.storeName,
  }) : super(key: key);

  @override
  State<TillImageGallery> createState() => _TillImageGalleryState();
}

class _TillImageGalleryState extends State<TillImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<TillImage> get allImages {
    // Safely access images, return empty list if null
    return widget.till.images ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final images = allImages;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Till ${widget.till.number} - ${widget.storeName}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: images.isEmpty
          ? const Center(
              child: Text(
                'No images available for this till.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final tillImage = images[index];
                    return Center(
                      child: Image.network(
                        tillImage.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 100,
                          );
                        },
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        'Captured: ${_formatDateTime(images[_currentIndex].timestamp)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _pageController.animateToPage(
                              entry.key,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            ),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).primaryColor)
                                    .withOpacity(
                                        _currentIndex == entry.key ? 0.9 : 0.4),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
