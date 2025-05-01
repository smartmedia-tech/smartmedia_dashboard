import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/usecases/get_campaign.dart';
import 'campaign_event.dart';
import 'campaign_state.dart';
import '../../domain/usecases/create_campaign.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final CreateCampaign createCampaignUsecase;
  final GetCampaigns getCampaignsUsecase;

  CampaignBloc(this.createCampaignUsecase, this.getCampaignsUsecase)
      : super(CampaignInitial()) {
    on<LoadCampaigns>((event, emit) async {
      emit(CampaignLoading());
      try {
        final campaigns = await getCampaignsUsecase();
        emit(CampaignLoaded(campaigns));
      } catch (e) {
        debugPrint(e.toString());
        emit(CampaignError(e.toString()));
      }
    });

    on<AddCampaign>((event, emit) async {
      try {
        await createCampaignUsecase(event.campaign);
        add(LoadCampaigns());
      } catch (e) {
         debugPrint(e.toString());
        emit(CampaignError(e.toString()));
      }
    });
  }
}
