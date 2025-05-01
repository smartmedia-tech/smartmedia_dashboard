import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';

abstract class CampaignRepository {
  Future<void> createCampaign(Campaign campaign);
  Future<List<Campaign>> getCampaigns();
}
