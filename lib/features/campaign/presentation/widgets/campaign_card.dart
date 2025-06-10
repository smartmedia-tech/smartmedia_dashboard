import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';

class CampaignCard extends StatelessWidget {
  final CampaignEntity campaign;
  final VoidCallback onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(
          bottom: 8.0), // Added for minimal spacing between cards
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(12.0), // Reduced padding for compactness
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Image
              if (campaign.clientLogoUrl != null)
                Container(
                  width: 80, // Fixed width for the image
                  height: 80, // Fixed height for the image
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        8.0), // Slightly rounded corners for the image
                    image: DecorationImage(
                      image: NetworkImage(campaign.clientLogoUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(Icons.business,
                      color: Colors.grey[600]), // Placeholder icon
                ),
              const SizedBox(width: 12), // Spacing between image and text

              // Right Column: Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      campaign.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            campaign.status.name.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10), // Smaller font for chip
                          ),
                          backgroundColor: _getStatusColor(campaign.status),
                          visualDensity:
                              VisualDensity.compact, // Compact chip size
                        ),
                        const Spacer(),
                        Text(
                          '${campaign.occupiedTills}/${campaign.totalTills} tills',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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

  Color _getStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.active:
        return Colors.green;
      case CampaignStatus.paused:
        return Colors.orange;
      case CampaignStatus.completed:
        return Colors.blue;
      case CampaignStatus.draft:
        return Colors.grey;
      case CampaignStatus.archived:
        return Colors.red;
    }
  }
}
