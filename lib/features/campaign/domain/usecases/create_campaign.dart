import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class CreateCampaign {
  final CampaignRepository repository;
  CreateCampaign(this.repository);

  Future<void> call(Campaign campaign) => repository.createCampaign(campaign);
}
