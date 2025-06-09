// lib/features/campaign/data/repositories/campaign_repository_impl.dart
import 'dart:io';

import '../../domain/repositories/campaign_repository.dart';
import '../../domain/entities/campaign_entity.dart';
import '../../domain/entities/campaign.dart'; // Import the concrete Campaign entity
import '../datasources/campaign_remote_data_source.dart';
import '../models/campaign_model.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignRemoteDataSource remoteDataSource;

  CampaignRepositoryImpl({required this.remoteDataSource});

  // Admin-specific operations
  @override
  Future<String> createCampaign(CampaignEntity campaignEntity) async {
    // Convert CampaignEntity (which will be a Campaign instance) to CampaignModel
    final model = CampaignModel.fromCampaignEntity(campaignEntity);
    return await remoteDataSource.createCampaign(model);
  }

  @override
  Future<void> updateCampaign(CampaignEntity campaignEntity) async {
    // Convert CampaignEntity (which will be a Campaign instance) to CampaignModel
    final model = CampaignModel.fromCampaignEntity(campaignEntity);
    await remoteDataSource.updateCampaign(model);
  }

  @override
  Future<void> deleteCampaign(String id) async {
    await remoteDataSource.deleteCampaign(id);
  }

  @override
  Future<String> uploadCampaignImage(String campaignId, File imageFile) async {
    return await remoteDataSource.uploadCampaignImage(campaignId, imageFile);
  }

  @override
  Future<void> changeCampaignStatus(String id, CampaignStatus status) async {
    await remoteDataSource.changeCampaignStatus(id, status);
  }

  // Data fetching and enrichment operations
  @override
  Future<CampaignEntity> getCampaign(String id) async {
    final campaignModel = await remoteDataSource.getCampaign(id);
    // Convert CampaignModel back to Campaign entity for the domain layer
    return Campaign.fromCampaignModel(campaignModel);
  }

  @override
  Future<List<CampaignEntity>> getCampaigns(
      {int limit = 10, String? lastId}) async {
    final campaignModels =
        await remoteDataSource.getCampaigns(limit: limit, lastId: lastId);
    // Convert list of CampaignModels to list of Campaign entities
    return campaignModels
        .map((model) => Campaign.fromCampaignModel(model))
        .toList();
  }

  @override
  Future<List<CampaignEntity>> getCampaignsWithStores() async {
    final campaignModels = await remoteDataSource.getCampaignsWithStores();
    return campaignModels
        .map((model) => Campaign.fromCampaignModel(model))
        .toList();
  }

  @override
  Future<List<CampaignEntity>> getActiveCampaignsWithStores() async {
    final campaignModels =
        await remoteDataSource.getActiveCampaignsWithStores();
    return campaignModels
        .map((model) => Campaign.fromCampaignModel(model))
        .toList();
  }

  @override
  Future<List<CampaignEntity>> getCampaignsForStore(String storeId) async {
    final campaignModels = await remoteDataSource.getCampaignsForStore(storeId);
    return campaignModels
        .map((model) => Campaign.fromCampaignModel(model))
        .toList();
  }
}
