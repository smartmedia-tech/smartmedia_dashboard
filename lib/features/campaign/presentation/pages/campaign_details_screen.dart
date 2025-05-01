import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailsScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('MMM dd, yyyy');
    final now = DateTime.now();
    final isActive =
        now.isAfter(campaign.startDate) && now.isBefore(campaign.endDate);
    final isUpcoming = now.isBefore(campaign.startDate);
    final daysLeft = isUpcoming
        ? campaign.startDate.difference(now).inDays
        : campaign.endDate.difference(now).inDays;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: Hero(
              tag: 'campaign-${campaign.id}',
              child: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: campaign.clientLogoUrl ??
                      'https://via.placeholder.com/600x300?text=${campaign.name}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
                title: Text(
                  campaign.name,
                  style: const TextStyle(
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Chip & Dates
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.2)
                              : isUpcoming
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive
                              ? 'Active'
                              : isUpcoming
                                  ? 'Upcoming'
                                  : 'Completed',
                          style: TextStyle(
                            color: isActive
                                ? Colors.green
                                : isUpcoming
                                    ? Colors.blue
                                    : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today,
                          size: 16, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        formatter.format(campaign.startDate),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.arrow_forward, size: 16),
                      ),
                      Text(
                        formatter.format(campaign.endDate),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Campaign Description
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Campaign Progress
                  if (isActive || isUpcoming) ...[
                    Text(
                      isActive ? 'Campaign Progress' : 'Starts In',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isActive) ...[
                                LinearProgressIndicator(
                                  value: now
                                          .difference(campaign.startDate)
                                          .inDays /
                                      campaign.endDate
                                          .difference(campaign.startDate)
                                          .inDays,
                                  backgroundColor: Colors.grey[200],
                                  color: theme.primaryColor,
                                  minHeight: 8,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${((now.difference(campaign.startDate).inDays / campaign.endDate.difference(campaign.startDate).inDays * 100).toStringAsFixed(0))}% completed',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$daysLeft days until start',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              Text(
                                '${campaign.endDate.difference(now).inDays}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              Text(
                                'days left',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Client Information
                  ...[
                  Text(
                    'Client',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: campaign.clientLogoUrl != null
                        ? CircleAvatar(
                            radius: 24,
                            backgroundImage: CachedNetworkImageProvider(
                                campaign.clientLogoUrl!),
                          )
                        : const CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.business),
                          ),
                    title: Text(
                      campaign.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text('Campaign Client'),
                  ),
                  const SizedBox(height: 24),
                ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.map),
                          label: const Text('View Stores'),
                          onPressed: () {
                            // Navigate to stores
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('View Photos'),
                          onPressed: () {
                            // Navigate to photos
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}
