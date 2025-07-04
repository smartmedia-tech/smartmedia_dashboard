import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/reports/domain/entities/report.dart';
import 'package:smartmedia_campaign_manager/features/reports/domain/repositories/reports_repository.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'reports_event.dart';

part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _reportsRepository;

  ReportsBloc(this._reportsRepository) : super(ReportsInitial()) {
    on<LoadReports>(_onLoadReports);
    on<SelectCampaign>(_onSelectCampaign);
    on<GenerateReport>(_onGenerateReport);
    on<DeleteReport>(_onDeleteReport);
    on<LoadStoresForCampaign>(_onLoadStoresForCampaign);
  }

  Future<void> _onLoadReports(
      LoadReports event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final reports = await _reportsRepository.getReports();
      emit(ReportsLoaded(reports: reports));
    } catch (e) {
      debugPrint('Error loading reports: ${e.toString()}');
      emit(ReportsError('Failed to load reports: ${e.toString()}'));
    }
  }

  Future<void> _onSelectCampaign(
      SelectCampaign event, Emitter<ReportsState> emit) async {
    // We assume here that ReportsLoaded state is already active.
    // If not, consider handling other states or ensuring this event is dispatched only when appropriate.
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      emit(currentState.copyWith(
          selectedCampaign: event.campaign,
          campaignStores: [])); // Clear stores on new selection
      add(LoadStoresForCampaign(event.campaign.id));
    } else {
      // If not in ReportsLoaded, you might want to transition to a loading state first
      // or handle this as an invalid operation. For now, it will just not update.
      debugPrint(
          'ReportsBloc: SelectCampaign called in unexpected state: $state');
    }
  }

  Future<void> _onLoadStoresForCampaign(
      LoadStoresForCampaign event, Emitter<ReportsState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      try {
        final stores =
            await _reportsRepository.getStoresForCampaign(event.campaignId);
        emit(currentState.copyWith(campaignStores: stores));
      } catch (e) {
        debugPrint('Error loading stores: ${e.toString()}');
        emit(
            currentState.copyWith(campaignStores: [])); // Clear stores on error
        emit(ReportsError(
            'Failed to load stores for campaign: ${e.toString()}'));
      }
    } else {
      debugPrint(
          'ReportsBloc: LoadStoresForCampaign called in unexpected state: $state');
      // Potentially emit an error or transition to a loading state if needed.
    }
  }

  Future<void> _onGenerateReport(
      GenerateReport event, Emitter<ReportsState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      emit(currentState.copyWith(isGeneratingReport: true));

      try {
        final stores =
            await _reportsRepository.getStoresForCampaign(event.campaign.id);
        final report =
            await _reportsRepository.generateReport(event.campaign, stores);

        final updatedReports = [report, ...currentState.reports];
        emit(currentState.copyWith(
          reports: updatedReports,
          isGeneratingReport: false,
        ));
        emit(ReportGenerated(report)); // Emit a separate success state
      } catch (e) {
        debugPrint('Error generating report: ${e.toString()}');
        emit(currentState.copyWith(isGeneratingReport: false));
        emit(ReportsError('Failed to generate report: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteReport(
      DeleteReport event, Emitter<ReportsState> emit) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      try {
        await _reportsRepository.deleteReport(event.reportId);
        final updatedReports = currentState.reports
            .where((report) => report.id != event.reportId)
            .toList();
        emit(currentState.copyWith(reports: updatedReports));
      } catch (e) {
        debugPrint('Error deleting report: ${e.toString()}');
        emit(ReportsError('Failed to delete report: ${e.toString()}'));
      }
    }
  }
}
