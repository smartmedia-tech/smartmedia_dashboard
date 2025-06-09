// lib/features/campaign/domain/repositories/campaign_repository.dart
import 'dart:io';

import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';

abstract class CampaignRepository {
  // Admin-specific methods
  Future<String> createCampaign(CampaignEntity campaign);
  Future<void> updateCampaign(CampaignEntity campaign);
  Future<void> deleteCampaign(String id);
  Future<String> uploadCampaignImage(String campaignId, File imageFile);
  Future<void> changeCampaignStatus(String id, CampaignStatus status);
  // Data fetching and enrichment methods (now implicitly include store/till data)
  Future<CampaignEntity> getCampaign(
      String id); // This will return a fully enriched CampaignEntity
  Future<List<CampaignEntity>> getCampaigns(
      {int limit = 10, String? lastId}); // This will return enriched campaigns
  Future<List<CampaignEntity>>
      getCampaignsWithStores(); // Already enriched by the data source
  Future<List<CampaignEntity>>
      getActiveCampaignsWithStores(); // Already enriched by the data source
  Future<List<CampaignEntity>> getCampaignsForStore(
      String storeId); // Already enriched by the data source
}
