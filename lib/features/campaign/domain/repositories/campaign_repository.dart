import 'dart:io';

import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';

abstract class CampaignRepository {
  Future<void> createCampaign(Campaign campaign);
  Future<List<Campaign>> getCampaigns({int limit = 10, String? lastId});
  Future<Campaign> getCampaign(String id);
  Future<void> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
  Future<void> changeCampaignStatus(String id, CampaignStatus status);
  Future<String> uploadCampaignImage(String campaignId, File imageFile);
}
