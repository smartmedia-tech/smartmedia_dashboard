import 'package:smartmedia_campaign_manager/features/campaign/data/repositories/deployment_repository.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_deployment.dart';

class GetCampaignDeploymentUseCase  {
  final DeploymentRepository repository;

  GetCampaignDeploymentUseCase(this.repository);

  
  Future<List<CampaignDeployment>> getCampaignDeployments(String campaignId) =>
      repository.getCampaignDeployments(campaignId);
}
