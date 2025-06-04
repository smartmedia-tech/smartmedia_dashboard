import 'dart:io';
import 'package:smartmedia_campaign_manager/features/campaign/data/repositories/deployment_repository.dart';


class DeployCampaignUseCase {
  final DeploymentRepository repository;

  DeployCampaignUseCase(this.repository);

  
  Future<void> deployCampaignToTill({
    required String campaignId,
    required String storeId,
    required String tillId,
    required File imageFile,
  }) =>
      repository.deployCampaignToTill(
        campaignId: campaignId,
        storeId: storeId,
        tillId: tillId,
        imageFile: imageFile,
      );
}
