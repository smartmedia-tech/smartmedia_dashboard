import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';


import '../repositories/campaign_repository.dart';

class GetCampaigns {
  final CampaignRepository repository;
  GetCampaigns(this.repository);

  Future<List<CampaignEntity>> call() => repository.getCampaigns();
}
