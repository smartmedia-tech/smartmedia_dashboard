import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class GetCampaign {
  final CampaignRepository repository;
  GetCampaign(this.repository);

  Future<Campaign> call(String id) => repository.getCampaign(id);
}
