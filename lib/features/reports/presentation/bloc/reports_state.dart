part of 'reports_bloc.dart';


abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<Report> reports;
  final Campaign? selectedCampaign;
  final List<Store> campaignStores;
  final bool isGeneratingReport;

  const ReportsLoaded({
    required this.reports,
    this.selectedCampaign,
    this.campaignStores = const [],
    this.isGeneratingReport = false,
  });

  @override
  List<Object?> get props =>
      [reports, selectedCampaign, campaignStores, isGeneratingReport];

  ReportsLoaded copyWith({
    List<Report>? reports,
    Campaign? selectedCampaign,
    List<Store>? campaignStores,
    bool? isGeneratingReport,
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      selectedCampaign: selectedCampaign ?? this.selectedCampaign,
      campaignStores: campaignStores ?? this.campaignStores,
      isGeneratingReport: isGeneratingReport ?? this.isGeneratingReport,
    );
  }
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportGenerated extends ReportsState {
  final Report report;

  const ReportGenerated(this.report);

  @override
  List<Object?> get props => [report];
}
