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
    final theme = Theme.of(context);
    final activeTills = store.tills.where((t) => t.isOccupied).length;
    final totalTills = store.tills.length;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering
                  ? theme.primaryColor.withOpacity(0.5)
                  : theme.dividerColor,
              width: isHovering ? 1.5 : 1.0,
            ),
            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section (40% of card)
              Flexible(
                flex: 4,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    color: Colors.grey[100],
                    child: store.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: store.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.primaryColor,
                              ),
                            ),
                            errorWidget: (_, __, ___) => Center(
                              child: Icon(
                                Icons.error_outline,
                                size: 40,
                                color: Colors.grey[300],
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.store_mall_directory,
                              size: 40,
                              color: Colors.grey[300],
                            ),
                          ),
                  ),
                ),
              ),

              // Info Section (60% of card)
              Flexible(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Store Name
                      Text(
                        store.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Till Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTillIndicator(
                            context,
                            'Total',
                            totalTills.toString(),
                            Icons.point_of_sale,
                          ),
                          _buildTillIndicator(
                            context,
                            'Active',
                            '$activeTills/$totalTills',
                            Icons.check_circle,
                            isActive: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTillIndicator(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isActive = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Colors.green[600]
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green[600] : null,
                  ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}
