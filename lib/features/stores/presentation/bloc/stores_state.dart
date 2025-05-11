import 'package:equatable/equatable.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

abstract class StoresState extends Equatable {
  const StoresState();

  @override
  List<Object?> get props => [];
}

class StoresInitial extends StoresState {}

class StoresLoading extends StoresState {}

class StoresLoaded extends StoresState {
  final List<Store> stores;

  const StoresLoaded(this.stores);

  @override
  List<Object> get props => [stores];
}

class StoreAdded extends StoresState {
  final Store store;

  const StoreAdded(this.store);

  @override
  List<Object> get props => [store];
}

class StoreUpdated extends StoresState {
  final Store store;

  const StoreUpdated(this.store);

  @override
  List<Object> get props => [store];
}

class StoreDeleted extends StoresState {
  final String storeId;

  const StoreDeleted(this.storeId);

  @override
  List<Object> get props => [storeId];
}

class ImageUploading extends StoresState {}

class StoreImageUploaded extends StoresState {
  final String storeId;
  final String imageUrl;

  const StoreImageUploaded({
    required this.storeId,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [storeId, imageUrl];
}

class TillImagesLoaded extends StoresState {
  final List<String> images;

  const TillImagesLoaded(this.images);

  @override
  List<Object> get props => [images];
}

class TillImageUploaded extends StoresState {
  final String storeId;
  final String tillId;
  final String imageUrl;

  const TillImageUploaded({
    required this.storeId,
    required this.tillId,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [storeId, tillId, imageUrl];
}

class StoreAddedSuccess extends StoresState {
  const StoreAddedSuccess();

  @override
  List<Object> get props => [];
}

class TillStatusUpdated extends StoresState {
  final String storeId;
  final String tillId;
  final bool isOccupied;

  const TillStatusUpdated({
    required this.storeId,
    required this.tillId,
    required this.isOccupied,
  });

  @override
  List<Object> get props => [storeId, tillId, isOccupied];
}

class StoresError extends StoresState {
  final String message;

  const StoresError(this.message);

  @override
  List<Object> get props => [message];
}

class LoadingTillImages extends StoresState {
  @override
  List<Object> get props => [];
}

class TillImagesError extends StoresState {
  final String message;

  const TillImagesError(this.message);

  @override
  List<Object> get props => [message];
}

class StoresFilteredState extends StoresState {
  final List<Store> filteredStores;
  final String searchQuery;
  final String? regionFilter;
  final List<Store> allStores;

  const StoresFilteredState({
    required this.filteredStores,
    required this.searchQuery,
    this.regionFilter,
    required this.allStores,
  });

  @override
  List<Object?> get props =>
      [filteredStores, searchQuery, regionFilter, allStores];
}
