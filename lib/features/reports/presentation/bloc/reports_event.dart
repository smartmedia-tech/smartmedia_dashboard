import 'package:equatable/equatable.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReports extends ReportsEvent {}

class SelectCampaign extends ReportsEvent {
  final Campaign campaign;

  const SelectCampaign(this.campaign);

  @override
  List<Object?> get props => [campaign];
}

class GenerateReport extends ReportsEvent {
  final Campaign campaign;

  const GenerateReport(this.campaign);

  @override
  List<Object?> get props => [campaign];
}

class DeleteReport extends ReportsEvent {
  final String reportId;

  const DeleteReport(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class LoadStoresForCampaign extends ReportsEvent {
  final String campaignId;

  const LoadStoresForCampaign(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}
