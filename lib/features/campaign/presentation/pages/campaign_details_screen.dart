import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/widgets/web_campaign_images_section.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/widgets/web_campaign_stores_section.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final CampaignEntity campaign;

  const CampaignDetailsScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildProgressSection(context),
            const SizedBox(height: 32),
            WebCampaignStoresSection(campaign: campaign),
            const SizedBox(height: 32),
            WebCampaignImagesSection(campaign: campaign),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (campaign.clientLogoUrl != null)
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(campaign.clientLogoUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campaign.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                campaign.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  campaign.status.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _getStatusColor(campaign.status),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campaign Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${(campaign.progressPercentage * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: campaign.progressPercentage,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start: ${campaign.startDate.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'End: ${campaign.endDate.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
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
