import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';


import '../repositories/campaign_repository.dart';

class GetCampaign {
  final CampaignRepository repository;
  GetCampaign(this.repository);

  Future<CampaignEntity> call(String id) => repository.getCampaign(id);
}
