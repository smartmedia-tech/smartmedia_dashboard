import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';

class WebCampaignStoresSection extends StatelessWidget {
  final CampaignEntity campaign;

  const WebCampaignStoresSection({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    if (campaign.populatedStores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deployed Stores (${campaign.totalStores})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // Increased for more compact layout
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5, // Adjusted for minimal height
          ),
          itemCount: campaign.populatedStores.length,
          itemBuilder: (context, index) {
            final store = campaign.populatedStores[index];
            return _StoreCard(store: store);
          },
        ),
      ],
    );
  }
}

class _StoreCard extends StatefulWidget {
  final dynamic store; // Replace with your actual Store entity type

  const _StoreCard({required this.store});

  @override
  State<_StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<_StoreCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tillsRatio = widget.store.totalTills > 0
        ? widget.store.occupiedTillsCount / widget.store.totalTills
        : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header row with store icon and region
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.store,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.store.region,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Store name
              Text(
                widget.store.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Tills info with progress indicator
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.store.occupiedTillsCount}/${widget.store.totalTills} tills',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Progress bar
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: tillsRatio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getTillsStatusColor(tillsRatio),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicator
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getTillsStatusColor(tillsRatio),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTillsStatusColor(double ratio) {
    if (ratio >= 0.8) return Colors.green;
    if (ratio >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
