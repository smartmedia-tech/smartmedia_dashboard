import 'dart:io';
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
      status: campaign.status,
    );
    await remoteDataSource.createCampaign(model);
  }

  @override
  Future<List<Campaign>> getCampaigns({int limit = 10, String? lastId}) async {
    return await remoteDataSource.getCampaigns(limit: limit, lastId: lastId);
  }

  @override
  Future<Campaign> getCampaign(String id) async {
    return await remoteDataSource.getCampaign(id);
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    final model = CampaignModel(
      id: campaign.id,
      name: campaign.name,
      description: campaign.description,
      startDate: campaign.startDate,
      endDate: campaign.endDate,
      clientLogoUrl: campaign.clientLogoUrl,
      status: campaign.status,
    );
    await remoteDataSource.updateCampaign(model);
  }

  @override
  Future<void> deleteCampaign(String id) async {
    await remoteDataSource.deleteCampaign(id);
  }

  @override
  Future<void> changeCampaignStatus(String id, CampaignStatus status) async {
    await remoteDataSource.changeCampaignStatus(id, status);
  }

  @override
  Future<String> uploadCampaignImage(String campaignId, File imageFile) async {
    return await remoteDataSource.uploadCampaignImage(campaignId, imageFile);
  }
}
