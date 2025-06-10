// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';

class CampaignCard extends StatelessWidget {
  final CampaignEntity campaign;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2, // Added a slight elevation for better visual
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          // Ensures the row takes the height of its tallest child
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image taking full height
              if (campaign.clientLogoUrl != null)
                Container(
                  width: 160, // Reduced width for the image
                  // height: 50, // Removed fixed height as IntrinsicHeight will manage
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(campaign.clientLogoUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Content column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Campaign info at the top
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('MMM d').format(campaign.startDate)} - ${DateFormat('MMM d, y').format(campaign.endDate)}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(campaign.status.name.toUpperCase()),
                            backgroundColor:
                                campaign.status == CampaignStatus.active
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: campaign.status == CampaignStatus.active
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      // Buttons at the bottom
                             Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Edit button
                          SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: onEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(60, 28),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child:const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, size: 14),
                                   SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delete button
                          SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: onDelete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(70, 28),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child:const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete, size: 14),
                                   SizedBox(width: 4),
                                  Text(
                                    'Delete',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
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
}
