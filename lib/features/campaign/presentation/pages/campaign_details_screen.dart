import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/core/utils/function_utils.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final Campaign campaign;
  final Function(Campaign) onEdit;
  final Function(String) onDelete;
  final VoidCallback onBack;

  const CampaignDetailsScreen({
    super.key,
    required this.campaign,
    required this.onEdit,
    required this.onDelete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = getStatusColor(campaign.status);
    final now = DateTime.now();
    final isActive =
        now.isAfter(campaign.startDate) && now.isBefore(campaign.endDate);
    final dateFormatter = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campaign Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Campaign',
            onPressed: () => onEdit(campaign),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Campaign',
            onPressed: () => onDelete(campaign.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with image
            AspectRatio(
              aspectRatio: 21 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: campaign.clientLogoUrl ??
                        getPlaceholderUrl(campaign.name),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.business,
                          size: 64, color: Colors.grey),
                    ),
                  ),
                  // Gradient overlay for text visibility
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Campaign name overlay
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                campaign.status
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          campaign.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
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
                  const Divider(),
                  const SizedBox(height: 24),

                  // Details grid - Adapted for web with responsive layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth / 2) - 16
                                : constraints.maxWidth,
                            child: _buildDetailItem(
                              context,
                              'Date Range',
                              '${dateFormatter.format(campaign.startDate)} - ${dateFormatter.format(campaign.endDate)}',
                              Icons.date_range,
                            ),
                          ),
                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth / 2) - 16
                                : constraints.maxWidth,
                            child: _buildDetailItem(
                              context,
                              'Duration',
                              '${campaign.endDate.difference(campaign.startDate).inDays} days',
                              Icons.timelapse,
                            ),
                          ),
                          if (isActive)
                            SizedBox(
                              width: isWide
                                  ? (constraints.maxWidth / 2) - 16
                                  : constraints.maxWidth,
                              child: _buildDetailItem(
                                context,
                                'Days Remaining',
                                '${campaign.endDate.difference(now).inDays} days',
                                Icons.hourglass_bottom,
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  // Progress bar if active
                  if (isActive) ...[
                    const SizedBox(height: 24),
                    _buildProgressSection(campaign.startDate, campaign.endDate),
                  ],

                  const SizedBox(height: 48),

                  // Action buttons for bottom of content area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => onDelete(campaign.id),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete Campaign',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () => onEdit(campaign),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Campaign'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(DateTime start, DateTime end) {
    final now = DateTime.now();
    final totalDuration = end.difference(start).inDays;
    final elapsedDuration = now.difference(start).inDays;
    final progress = elapsedDuration / totalDuration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campaign Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Day ${elapsedDuration + 1} of $totalDuration',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% Complete',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          color: Colors.blue,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM dd').format(start),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              DateFormat('MMM dd').format(end),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}
