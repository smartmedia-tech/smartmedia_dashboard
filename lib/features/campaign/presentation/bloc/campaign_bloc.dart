import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/usecases/upload_image.dart';
import '../../domain/usecases/change_campaign_status.dart';
import '../../domain/usecases/create_campaign.dart';
import '../../domain/usecases/get_campaign.dart';
import '../../domain/usecases/get_campaigns.dart';
import '../../domain/usecases/update_campaign.dart' as update_usecase;
import '../../domain/usecases/delete_campaign.dart' as delete_usecase;

import 'campaign_event.dart';
import 'campaign_state.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final CreateCampaign createCampaign;
  final GetCampaigns getCampaigns;
  final GetCampaign getCampaign;
  final update_usecase.UpdateCampaign updateCampaign;
  final delete_usecase.DeleteCampaign deleteCampaign;
  final ChangeCampaignStatus changeCampaignStatus;
  final UploadCampaignImage uploadCampaignImage;

  CampaignBloc({
    required this.createCampaign,
    required this.getCampaigns,
    required this.getCampaign,
    required this.updateCampaign,
    required this.deleteCampaign,
    required this.changeCampaignStatus,
    required this.uploadCampaignImage,
  }) : super(CampaignInitial()) {
    on<LoadCampaigns>(_onLoadCampaigns);
    on<LoadMoreCampaigns>(_onLoadMoreCampaigns);
    on<AddCampaign>(_onAddCampaign);
    on<UpdateCampaign>(_onUpdateCampaign);
    on<DeleteCampaign>(_onDeleteCampaign);
    on<ChangeCampaignStatusEvent>(_onChangeCampaignStatus);
    on<GetCampaignDetails>(_onGetCampaignDetails);
    on<UploadCampaignImageEvent>(_onUploadCampaignImage);
    on<FilterCampaigns>(_onFilterCampaigns);
  }
  Future<void> _onFilterCampaigns(
    FilterCampaigns event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      // Get all campaigns first
      final allCampaigns = await getCampaigns();

      // Apply filters
      List<CampaignEntity> filteredCampaigns = allCampaigns.where((campaign) {
        // Search query filter
        final matchesSearch = event.searchQuery.isEmpty ||
            campaign.name
                .toLowerCase()
                .contains(event.searchQuery.toLowerCase()) ||
            campaign.description
                .toLowerCase()
                .contains(event.searchQuery.toLowerCase());

        // Status filter
        final matchesStatus =
            event.status == null || campaign.status == event.status;

        return matchesSearch && matchesStatus;
      }).toList();

      emit(CampaignsLoaded(
        campaigns: filteredCampaigns,
        hasReachedMax: true, // Since we're filtering existing data
        lastId: null,
      ));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> _onUploadCampaignImage(
    UploadCampaignImageEvent event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      emit(const CampaignLoading());
      final imageUrl = await uploadCampaignImage(
        event.campaignId,
        event.imageFile,
      );

      emit(CampaignImageUploaded(imageUrl));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> _onLoadCampaigns(
    LoadCampaigns event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      emit(const CampaignLoading());
      final campaigns = await getCampaigns();
      emit(CampaignsLoaded(
        campaigns: campaigns,
        hasReachedMax: campaigns.length < event.limit,
        lastId: campaigns.isNotEmpty ? campaigns.last.id : null,
      ));
    } catch (e) {
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> _onLoadMoreCampaigns(
    LoadMoreCampaigns event,
    Emitter<CampaignState> emit,
  ) async {
    final currentState = state;
    if (currentState is CampaignsLoaded && currentState.hasReachedMax) return;

    try {
      if (currentState is CampaignsLoaded) {
        emit(CampaignLoading(campaigns: currentState.campaigns));

        final campaigns = await getCampaigns(
            // limit: event.limit,
            // lastId: event.lastId,
            );

        emit(
          campaigns.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : CampaignsLoaded(
                  campaigns: [...currentState.campaigns, ...campaigns],
                  hasReachedMax: campaigns.length < event.limit,
                  lastId: campaigns.isNotEmpty ? campaigns.last.id : null,
                ),
        );
      }
    } catch (e) {
      if (currentState is CampaignsLoaded) {
        emit(CampaignError(e.toString(), campaigns: currentState.campaigns));
      } else {
        emit(CampaignError(e.toString()));
      }
    }
  }

  Future<void> _onAddCampaign(
    AddCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      await createCampaign(event.campaign);
      emit(const CampaignOperationSuccess('Campaign created successfully'));
      add(const LoadCampaigns());
    } catch (e) {
      // Preserve current campaigns if available
      if (state is CampaignsLoaded) {
        final campaigns = (state as CampaignsLoaded).campaigns;
        emit(CampaignError(e.toString(), campaigns: campaigns));
      } else {
        emit(CampaignError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateCampaign(
    UpdateCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      await updateCampaign(event.campaign);
      emit(const CampaignOperationSuccess('Campaign updated successfully'));
      add(GetCampaignDetails(event.campaign.id));
    } catch (e) {
      // Preserve current campaigns if available
      if (state is CampaignsLoaded) {
        final campaigns = (state as CampaignsLoaded).campaigns;
        emit(CampaignError(e.toString(), campaigns: campaigns));
      } else {
        emit(CampaignError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteCampaign(
    DeleteCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      await deleteCampaign(event.id);
      emit(const CampaignOperationSuccess('Campaign deleted successfully'));
      add(const LoadCampaigns());
    } catch (e) {
      // Preserve current campaigns if available
      if (state is CampaignsLoaded) {
        final campaigns = (state as CampaignsLoaded).campaigns;
        emit(CampaignError(e.toString(), campaigns: campaigns));
      } else {
        emit(CampaignError(e.toString()));
      }
    }
  }

  Future<void> _onChangeCampaignStatus(
    ChangeCampaignStatusEvent event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      await changeCampaignStatus(event.id, event.status);
      emit(const CampaignOperationSuccess('Campaign status updated'));
      add(GetCampaignDetails(event.id));
    } catch (e) {
      // Preserve current campaigns if available
      if (state is CampaignsLoaded) {
        final campaigns = (state as CampaignsLoaded).campaigns;
        emit(CampaignError(e.toString(), campaigns: campaigns));
      } else {
        emit(CampaignError(e.toString()));
      }
    }
  }

  Future<void> _onGetCampaignDetails(
    GetCampaignDetails event,
    Emitter<CampaignState> emit,
  ) async {
    try {
      // If we already have campaigns loaded, keep them while loading details
      final currentCampaigns =
          state is CampaignsLoaded ? (state as CampaignsLoaded).campaigns : [];
      emit(CampaignLoading(campaigns: currentCampaigns.cast<CampaignEntity>()));

      final campaign = await getCampaign(event.id);
      emit(CampaignLoaded(campaign));
    } catch (e) {
      // Preserve current campaigns if available
      if (state is CampaignsLoaded) {
        final campaigns = (state as CampaignsLoaded).campaigns;
        emit(CampaignError(e.toString(), campaigns: campaigns));
      } else {
        emit(CampaignError(e.toString()));
      }
    }
  }
}
