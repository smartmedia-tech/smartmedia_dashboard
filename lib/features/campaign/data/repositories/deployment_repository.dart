import 'dart:io';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_deployment.dart';

abstract class DeploymentRepository {
  Future<void> deployCampaignToTill({
    required String campaignId,
    required String storeId,
    required String tillId,
    required File imageFile,
  });

  Future<void> removeCampaignFromTill({
    required String campaignId,
    required String storeId,
    required String tillId,
  });

  Future<List<CampaignDeployment>> getCampaignDeployments(String campaignId);
}
