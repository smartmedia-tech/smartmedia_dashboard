import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/repositories/store_repository.dart';
import 'package:uuid/uuid.dart';
import 'stores_event.dart';
import 'stores_state.dart';

class StoresBloc extends Bloc<StoresEvent, StoresState> {
  final StoreRepository _storeRepository;
  StreamSubscription? _storesSubscription;
  StoreRepository get repository => _storeRepository;

  StoresBloc({required StoreRepository storeRepository})
      : _storeRepository = storeRepository,
        super(StoresInitial()) {
    on<LoadStores>(_onLoadStores);
    on<RefreshStores>(_onRefreshStores);
    on<AddStore>(_onAddStore);
    on<UpdateStore>(_onUpdateStore);
    on<DeleteStore>(_onDeleteStore);
    on<UploadStoreImage>(_onUploadStoreImage);
    on<UpdateTillStatus>(_onUpdateTillStatus);
    on<UploadTillImage>(_onUploadTillImage);
    on<StoreDataReceived>(_onStoreDataReceived);
    on<SearchStores>(_onSearchStores);
    on<FilterStoresByRegion>(_onFilterStoresByRegion);
    on<FetchTillImages>(_onFetchTillImages);
  }
  Future<String> uploadStoreImage(String storeId, File imageFile) async {
    return await _storeRepository.uploadStoreImage(storeId, imageFile);
  }

  Future<void> _onLoadStores(
      LoadStores event, Emitter<StoresState> emit) async {
    if (state is! StoresLoaded) {
      emit(StoresLoading());
    }

    await _setupStoreSubscription();
  }

  Future<void> _onRefreshStores(
      RefreshStores event, Emitter<StoresState> emit) async {
    await _setupStoreSubscription();
  }

  void _onStoreDataReceived(
      StoreDataReceived event, Emitter<StoresState> emit) {
    // If we were filtering or searching before, maintain those filters
    if (state is StoresFilteredState) {
      final filteredState = state as StoresFilteredState;

      // Apply existing filters to new data
      final filteredStores = _applyFilters(
        event.stores,
        filteredState.searchQuery,
        filteredState.regionFilter,
      );

      emit(StoresFilteredState(
        filteredStores: filteredStores,
        searchQuery: filteredState.searchQuery,
        regionFilter: filteredState.regionFilter,
        allStores: event.stores,
      ));
    } else {
      // No filters applied before
      emit(StoresLoaded(event.stores));
    }
  }

  Future<void> _setupStoreSubscription() async {
    // Cancel existing subscription if any
    await _storesSubscription?.cancel();

    try {
      _storesSubscription = _storeRepository.getStores().listen(
        (stores) {
          add(StoreDataReceived(stores));
        },
        onError: (error) {
          add(StoreErrorReceived(error.toString()));
        },
      );
    } catch (e) {
      add(StoreErrorReceived(e.toString()));
    }
  }

// Add to stores_bloc.dart - new handlers
  Future<void> _onSearchStores(
      SearchStores event, Emitter<StoresState> emit) async {
    final List<Store> allStores;
    final String? currentRegionFilter;

    // Get current stores list and region filter
    if (state is StoresLoaded) {
      allStores = (state as StoresLoaded).stores;
      currentRegionFilter = null;
    } else if (state is StoresFilteredState) {
      allStores = (state as StoresFilteredState).allStores;
      currentRegionFilter = (state as StoresFilteredState).regionFilter;
    } else {
      return; // Can't search if not loaded
    }

    final filteredStores = _applyFilters(
      allStores,
      event.query,
      currentRegionFilter,
    );

    emit(StoresFilteredState(
      filteredStores: filteredStores,
      searchQuery: event.query,
      regionFilter: currentRegionFilter,
      allStores: allStores,
    ));
  }

  Future<void> _onFilterStoresByRegion(
      FilterStoresByRegion event, Emitter<StoresState> emit) async {
    final List<Store> allStores;
    final String currentSearchQuery;

    // Get current stores list and search query
    if (state is StoresLoaded) {
      allStores = (state as StoresLoaded).stores;
      currentSearchQuery = '';
    } else if (state is StoresFilteredState) {
      allStores = (state as StoresFilteredState).allStores;
      currentSearchQuery = (state as StoresFilteredState).searchQuery;
    } else {
      return; // Can't filter if not loaded
    }

    final filteredStores = _applyFilters(
      allStores,
      currentSearchQuery,
      event.region,
    );

    emit(StoresFilteredState(
      filteredStores: filteredStores,
      searchQuery: currentSearchQuery,
      regionFilter: event.region,
      allStores: allStores,
    ));
  }

// Helper method to apply search and region filters
  List<Store> _applyFilters(
      List<Store> stores, String searchQuery, String? regionFilter) {
    return stores.where((store) {
      // Apply region filter if specified
      if (regionFilter != null &&
          regionFilter.isNotEmpty &&
          store.region != regionFilter) {
        return false;
      }

      // Apply search query if not empty
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return store.name.toLowerCase().contains(query) ||
            store.siteNumber.toLowerCase().contains(query) ||
            store.region.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Future<void> close() {
    _storesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onAddStore(AddStore event, Emitter<StoresState> emit) async {
    try {
      emit(StoresLoading());

      // Generate storeId first
      final String storeId = const Uuid().v4();

      String? imageUrl;
      if (event.imageFile != null) {
        imageUrl = await _storeRepository.uploadStoreImage(
          storeId, // Use the real storeId
          event.imageFile!,
        );
      }

      await _storeRepository.addStore(
        name: event.name,
        region: event.region,
        siteNumber: event.siteNumber,
        tillCount: event.tillCount,
        imageUrl: imageUrl,
        id: storeId,
      );

      emit(const StoreAddedSuccess());
      add(LoadStores());
    } catch (e) {
      emit(StoresError('Failed to add store: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStore(
      UpdateStore event, Emitter<StoresState> emit) async {
    try {
      await _storeRepository.updateStore(event.store);
      emit(StoreUpdated(event.store));
      // Preserve current state if it's loaded
      if (state is StoresLoaded) {
        final currentStores = (state as StoresLoaded).stores;
        final updatedStores = currentStores.map((store) {
          return store.id == event.store.id ? event.store : store;
        }).toList();
        emit(StoresLoaded(updatedStores));
      }
    } catch (e) {
      emit(StoresError(e.toString()));
    }
  }

  Future<void> _onDeleteStore(
      DeleteStore event, Emitter<StoresState> emit) async {
    try {
      await _storeRepository.deleteStore(event.storeId);
      emit(StoreDeleted(event.storeId));
      // Update the list if we're in loaded state
      if (state is StoresLoaded) {
        final currentStores = (state as StoresLoaded).stores;
        final updatedStores =
            currentStores.where((store) => store.id != event.storeId).toList();
        emit(StoresLoaded(updatedStores));
      }
    } catch (e) {
      emit(StoresError(e.toString()));
    }
  }

  Future<void> _onUploadStoreImage(
      UploadStoreImage event, Emitter<StoresState> emit) async {
    try {
      emit(ImageUploading());
      final imageUrl = await _storeRepository.uploadStoreImage(
        event.storeId,
        event.imageFile,
      );
      emit(StoreImageUploaded(
        storeId: event.storeId,
        imageUrl: imageUrl,
      ));
    } catch (e) {
      emit(StoresError(e.toString()));
    }
  }

  Future<void> _onUpdateTillStatus(
      UpdateTillStatus event, Emitter<StoresState> emit) async {
    try {
      await _storeRepository.updateTillStatus(
        storeId: event.storeId,
        tillId: event.tillId,
        isOccupied: event.isOccupied,
      );
      emit(TillStatusUpdated(
        storeId: event.storeId,
        tillId: event.tillId,
        isOccupied: event.isOccupied,
      ));
    } catch (e) {
      emit(StoresError(e.toString()));
    }
  }

  Future<void> _onUploadTillImage(
    UploadTillImage event,
    Emitter<StoresState> emit,
  ) async {
    try {
      emit(ImageUploading());

      // Upload and update the till with new image
      await _storeRepository.updateTillWithImage(
        storeId: event.storeId,
        tillId: event.tillId,
        imageFile: event.imageFile,
      );

      // Fetch the updated images
      final images = await _storeRepository.fetchTillImages(
        storeId: event.storeId,
        tillId: event.tillId,
      );

      emit(TillImagesLoaded(images));

      // Refresh the store data
      add(LoadStores());
    } catch (e) {
      emit(TillImagesError('Failed to upload image: ${e.toString()}'));
    }
  }

  Future<void> _onFetchTillImages(
    FetchTillImages event,
    Emitter<StoresState> emit,
  ) async {
    try {
      emit(LoadingTillImages());

      final images = await _storeRepository.fetchTillImages(
        storeId: event.storeId,
        tillId: event.tillId,
      );

      emit(TillImagesLoaded(images));
    } catch (e) {
      emit(TillImagesError('Failed to fetch images: ${e.toString()}'));
    }
  }
}
