import 'dart:io';

import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';

import 'package:equatable/equatable.dart';

abstract class CampaignEvent extends Equatable {
  const CampaignEvent();

  @override
  List<Object?> get props => [];
}

class LoadCampaigns extends CampaignEvent {
  final int limit;
  final String? lastId;

  const LoadCampaigns({this.limit = 10, this.lastId});

  @override
  List<Object?> get props => [limit, lastId];
}

class LoadMoreCampaigns extends LoadCampaigns {
  const LoadMoreCampaigns({required super.limit, required String super.lastId});
}

class AddCampaign extends CampaignEvent {
  final CampaignEntity campaign;
  const AddCampaign(this.campaign);

  @override
  List<Object?> get props => [campaign];
}

class UpdateCampaign extends CampaignEvent {
  final CampaignEntity campaign;
  const UpdateCampaign(this.campaign);

  @override
  List<Object?> get props => [campaign];
}

class DeleteCampaign extends CampaignEvent {
  final String id;
  const DeleteCampaign(this.id);

  @override
  List<Object?> get props => [id];
}

class UploadCampaignImageEvent extends CampaignEvent {
  final String campaignId;
  final File imageFile;
  final String image;

  const UploadCampaignImageEvent({
    required this.campaignId,
    required this.imageFile,
    required this.image,
  });

  @override
  List<Object> get props => [campaignId, imageFile, image];
}

class ChangeCampaignStatusEvent extends CampaignEvent {
  final String id;
  final CampaignStatus status;
  const ChangeCampaignStatusEvent(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

class GetCampaignDetails extends CampaignEvent {
  final String id;
  const GetCampaignDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterCampaigns extends CampaignEvent {
  final String searchQuery;
  final CampaignStatus? status;

  const FilterCampaigns({required this.searchQuery, this.status});

  @override
  List<Object?> get props => [searchQuery, status];
}
class FetchCampaignsWithStores extends CampaignEvent {}

class FetchActiveCampaignsWithStores extends CampaignEvent {}

class FetchCampaignsForStore extends CampaignEvent {
  final String storeId;

  FetchCampaignsForStore(this.storeId);
}

class RefreshCampaigns extends CampaignEvent {
  final bool includeStores;

  RefreshCampaigns({this.includeStores = false});
}
