import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';

Color getStatusColor(CampaignStatus status) {
  switch (status) {
    case CampaignStatus.draft:
      return Colors.grey;
    case CampaignStatus.active:
      return Colors.green;
    case CampaignStatus.paused:
      return Colors.orange;
    case CampaignStatus.completed:
      return Colors.blue;
    case CampaignStatus.archived:
      return Colors.purple;
  }
}

String getPlaceholderUrl(String name) {
  return 'https://via.placeholder.com/600x400?text=${Uri.encodeComponent(name)}';
}
