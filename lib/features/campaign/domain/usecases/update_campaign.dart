import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class UpdateCampaign {
  final CampaignRepository repository;
  UpdateCampaign(this.repository);

  Future<void> call(Campaign campaign) => repository.updateCampaign(campaign);
}
