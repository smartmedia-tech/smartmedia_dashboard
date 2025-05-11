import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_image_card.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_images_empty.dart';

class TillImagesList extends StatelessWidget {
  final List<String> images;
  final ScrollController scrollController;
  final Till till;
  final Function(String) onImageTap;
  final Function(String) onDeleteImage;

  const TillImagesList({
    super.key,
    required this.images,
    required this.scrollController,
    required this.till,
    required this.onImageTap,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return TillImagesEmpty(till: till);
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TillImageCard(
            imageUrl: images[index],
            index: index,
            onTap: onImageTap,
            onDelete: onDeleteImage,
          ),
        );
      },
    );
  }
}
