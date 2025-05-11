import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';

class TillImagesEmpty extends StatelessWidget {
  final Till till;

  const TillImagesEmpty({super.key, required this.till});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No images available for Till ${till.number}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add images',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
