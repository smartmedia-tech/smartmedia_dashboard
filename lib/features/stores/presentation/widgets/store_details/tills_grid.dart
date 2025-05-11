import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/store_details/till_options_bottom_sheet.dart';

class TillsGrid extends StatelessWidget {
  final Store store;
  final String storeId;

  const TillsGrid({
    required this.store,
    required this.storeId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Separate tills into occupied and available
    final occupiedTills = store.tills.where((till) => till.isOccupied).toList();
    final availableTills =
        store.tills.where((till) => !till.isOccupied).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Occupied Tills Carousel (if any)
        if (occupiedTills.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 18, color: Colors.red.shade700),
              const SizedBox(width: 4),
              Text(
                'Occupied Tills',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          CarouselSlider.builder(
            itemCount: occupiedTills.length,
            options: CarouselOptions(
              height: 180,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              enableInfiniteScroll: occupiedTills.length > 1,
              autoPlay: occupiedTills.length > 1,
              autoPlayInterval: const Duration(seconds: 5),
            ),
            itemBuilder: (context, index, realIndex) {
              return OccupiedTillCard(
                till: occupiedTills[index],
                storeId: storeId,
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Available Tills Section
        if (availableTills.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.check_circle_outline,
                  size: 18, color: Colors.green.shade700),
              const SizedBox(width: 4),
              Text(
                'Available Tills',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableTills.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8, left: index == 0 ? 0 : 0),
                  child: CompactAvailableTillCard(
                    till: availableTills[index],
                    storeId: storeId,
                  ),
                );
              },
            ),
          ),
        ],

        // No tills message (unlikely but handling edge case)
        if (store.tills.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.info_outline,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No tills available for this store',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class OccupiedTillCard extends StatelessWidget {
  final Till till;
  final String storeId;

  const OccupiedTillCard({
    required this.till,
    required this.storeId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<String> images = [];
    if (till.imageUrl != null && till.imageUrl!.isNotEmpty) {
      images.add(till.imageUrl!);
    }

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => TillOptionsBottomSheet(
          storeId: storeId,
          till: till,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inner image carousel
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image carousel or error placeholder when images are empty
                  images.isEmpty
                      ? Container(
                          color: Colors.red.shade50,
                          child: Center(
                            child: Icon(
                              Icons.error_outline_outlined,
                              color: Colors.red.shade300,
                              size: 40,
                            ),
                          ),
                        )
                      : PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, imageIndex) {
                            return CachedNetworkImage(
                              imageUrl: images[imageIndex],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red.shade300,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.red.shade50,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.red.shade300,
                                    size: 40,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  // Status overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'OCCUPIED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                  // Indicator dots for multiple images (only show if we have more than one image)
                  if (images.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Till info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Till ${till.number}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
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

class CompactAvailableTillCard extends StatelessWidget {
  final Till till;
  final String storeId;

  const CompactAvailableTillCard({
    required this.till,
    required this.storeId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => TillOptionsBottomSheet(
          storeId: storeId,
          till: till,
        ),
      ),
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green.shade600,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Till ${till.number}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Available',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
