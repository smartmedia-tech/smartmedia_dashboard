import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;
  final bool isHovering;

  const StoreCard({
    required this.store,
    required this.onTap,
    this.isHovering = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHovering ? 0.1 : 0.05),
              blurRadius: isHovering ? 12 : 8,
              offset: isHovering ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isHovering
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: store.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: store.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Center(
                                  child: Icon(
                                    Icons.storefront_outlined,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.store,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store Name - Flexible to prevent overflow
                  Flexible(
                    child: Text(
                      store.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location - Flexible row
                  ...[
                  Flexible(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            store.region,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                  // Stats - Expanded to take available space
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: _buildStatItem(
                            context,
                            '${store.tills.length}',
                            'Tills',
                          ),
                        ),
                        Flexible(
                          child: _buildStatItem(
                            context,
                            '${store.tills.where((t) => t.isOccupied).length}',
                            'Active',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label,
      {Color color = Colors.deepPurple}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
