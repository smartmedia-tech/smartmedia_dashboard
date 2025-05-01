import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../datasources/campaign_remote_data_source.dart';
import '../models/campaign_model.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignRemoteDataSource remoteDataSource;

  CampaignRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createCampaign(Campaign campaign) async {
    final model = CampaignModel(
      id: '',
      name: campaign.name,
      description: campaign.description,
      startDate: campaign.startDate,
      endDate: campaign.endDate,
        clientLogoUrl: campaign.clientLogoUrl,
    );
    await remoteDataSource.createCampaign(model);
  }

  @override
  Future<List<Campaign>> getCampaigns() async {
    return await remoteDataSource.getCampaigns();
  }
}
