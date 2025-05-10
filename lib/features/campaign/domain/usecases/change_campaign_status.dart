import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class ChangeCampaignStatus {
  final CampaignRepository repository;
  ChangeCampaignStatus(this.repository);

  Future<void> call(String id, CampaignStatus status) =>
      repository.changeCampaignStatus(id, status);
}
