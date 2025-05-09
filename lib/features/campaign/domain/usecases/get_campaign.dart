import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

class GetCampaigns {
  final CampaignRepository repository;
  GetCampaigns(this.repository);

  Future<List<Campaign>> call() => repository.getCampaigns();
}
