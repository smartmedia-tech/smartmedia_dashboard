import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smartmedia_campaign_manager/core/utils/colors.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/pages/store_details_screen.dart';

class StoreCardAvatar extends StatelessWidget {
  final Store store;
  final bool isFirst;
  final bool isLast;

  static const double cardWidth = 100;
  static const double cardHeight = 150;

  const StoreCardAvatar({
    super.key,
    required this.store,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 4.0 : 0.0,
        right: isLast ? 4.0 : 8.0,
      ),
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFirst || isLast
                  ? Colors.transparent
                  : AppColors.accentColor.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildBackgroundImage(),
              _buildStoreInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreDetailsScreen(storeId: store.id),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final imageUrl = store.imageUrl ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Hero(
        tag: 'store_image_${store.id}',
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: cardWidth,
          height: cardHeight,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.store,
                color: Colors.grey[400],
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Hero(
          tag: 'store_name_${store.id}',
          child: Text(
            store.name,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
