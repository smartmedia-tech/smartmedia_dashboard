import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';


import '../repositories/campaign_repository.dart';

class UpdateCampaign {
  final CampaignRepository repository;
  UpdateCampaign(this.repository);

  Future<void> call(CampaignEntity campaign) => repository.updateCampaign(campaign);
}
