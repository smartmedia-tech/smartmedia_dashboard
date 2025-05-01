import '../../domain/entities/campaign.dart';

import 'package:equatable/equatable.dart';

abstract class CampaignState extends Equatable {
  const CampaignState();

  @override
  List<Object?> get props => [];
}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {}

class CampaignLoaded extends CampaignState {
  final List<Campaign> campaigns;

  const CampaignLoaded(this.campaigns);

  @override
  List<Object?> get props => [campaigns];
}

class CampaignAdded extends CampaignState {
  final Campaign campaign;

  const CampaignAdded(this.campaign);

  @override
  List<Object?> get props => [campaign];
}

class CampaignUpdated extends CampaignState {
  final Campaign campaign;

  const CampaignUpdated(this.campaign);

  @override
  List<Object?> get props => [campaign];
}

class CampaignDeleted extends CampaignState {
  final String id;

  const CampaignDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class CampaignError extends CampaignState {
  final String message;

  const CampaignError(this.message);

  @override
  List<Object?> get props => [message];
}
