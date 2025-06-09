import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';

import '../repositories/campaign_repository.dart';

class CreateCampaign {
  final CampaignRepository repository;
  CreateCampaign(this.repository);

  Future<void> call(CampaignEntity campaign) => repository.createCampaign(campaign);
}
