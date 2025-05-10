// delete_campaign.dart
import '../repositories/campaign_repository.dart';

class DeleteCampaign {
  final CampaignRepository repository;
  DeleteCampaign(this.repository);

  Future<void> call(String id) => repository.deleteCampaign(id);
}
