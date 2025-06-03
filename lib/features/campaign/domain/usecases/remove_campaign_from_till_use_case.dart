import 'package:smartmedia_campaign_manager/features/campaign/data/repositories/deployment_repository.dart';

class RemoveCampaignFromTillUseCase  {
  final DeploymentRepository repository;

  RemoveCampaignFromTillUseCase(this.repository);


  Future<void> removeCampaignFromTill({
    required String campaignId,
    required String storeId,
    required String tillId,
  }) =>
      repository.removeCampaignFromTill(
        campaignId: campaignId,
        storeId: storeId,
        tillId: tillId,
      );
}
