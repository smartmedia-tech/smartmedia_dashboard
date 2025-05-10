import '../../domain/entities/campaign.dart';
import 'package:equatable/equatable.dart';

abstract class CampaignState extends Equatable {
  const CampaignState();

  @override
  List<Object?> get props => [];
}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {
  final List<Campaign> campaigns;

  const CampaignLoading({this.campaigns = const []});

  @override
  List<Object?> get props => [campaigns];
}

class CampaignsLoaded extends CampaignState {
  final List<Campaign> campaigns;
  final bool hasReachedMax;
  final String? lastId;

  const CampaignsLoaded({
    required this.campaigns,
    this.hasReachedMax = false,
    this.lastId,
  });

  CampaignsLoaded copyWith({
    List<Campaign>? campaigns,
    bool? hasReachedMax,
    String? lastId,
  }) {
    return CampaignsLoaded(
      campaigns: campaigns ?? this.campaigns,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      lastId: lastId ?? this.lastId,
    );
  }

  @override
  List<Object?> get props => [campaigns, hasReachedMax, lastId];
}

class CampaignLoaded extends CampaignState {
  final Campaign campaign;
  const CampaignLoaded(this.campaign);

  @override
  List<Object?> get props => [campaign];
}

class CampaignOperationSuccess extends CampaignState {
  final String message;
  const CampaignOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CampaignImageUploaded extends CampaignState {
  final String imageUrl;

  const CampaignImageUploaded(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class CampaignError extends CampaignState {
  final String message;
  final List<Campaign> campaigns;

  const CampaignError(this.message, {this.campaigns = const []});

  @override
  List<Object?> get props => [message, campaigns];
}
