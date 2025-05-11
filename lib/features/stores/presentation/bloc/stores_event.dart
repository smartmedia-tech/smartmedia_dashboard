import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

abstract class StoresEvent extends Equatable {
  const StoresEvent();

  @override
  List<Object?> get props => [];
}

class RefreshStores extends StoresEvent {
  const RefreshStores();
}

class LoadStores extends StoresEvent {}

class StoreDataReceived extends StoresEvent {
  final List<Store> stores;

  const StoreDataReceived(this.stores);

  @override
  List<Object> get props => [stores];
}

//  event for handling errors from stream
class StoreErrorReceived extends StoresEvent {
  final String error;

  const StoreErrorReceived(this.error);

  @override
  List<Object> get props => [error];
}

class AddStore extends StoresEvent {
  final String name;
  final String region;
  final String siteNumber;
  final int tillCount;
  final File? imageFile;

  const AddStore({
    required this.name,
    required this.region,
    required this.siteNumber,
    required this.tillCount,
    this.imageFile,
  });

  @override
  List<Object?> get props => [name, region, siteNumber, tillCount, imageFile];
}

class UpdateStore extends StoresEvent {
  final Store store;

  const UpdateStore({required this.store});

  @override
  List<Object> get props => [store];
}

class DeleteStore extends StoresEvent {
  final String storeId;

  const DeleteStore({required this.storeId});

  @override
  List<Object> get props => [storeId];
}

class UploadStoreImage extends StoresEvent {
  final String storeId;
  final File imageFile;

  const UploadStoreImage({
    required this.storeId,
    required this.imageFile,
  });

  @override
  List<Object> get props => [storeId, imageFile];
}

class UpdateTillStatus extends StoresEvent {
  final String storeId;
  final String tillId;
  final bool isOccupied;

  const UpdateTillStatus({
    required this.storeId,
    required this.tillId,
    required this.isOccupied,
  });

  @override
  List<Object> get props => [storeId, tillId, isOccupied];
}

class UploadTillImage extends StoresEvent {
  final String storeId;
  final String tillId;
  final File imageFile;

  const UploadTillImage({
    required this.storeId,
    required this.tillId,
    required this.imageFile,
  });

  @override
  List<Object> get props => [storeId, tillId, imageFile];
}

class FetchTillImages extends StoresEvent {
  final String storeId;
  final String tillId;

  const FetchTillImages({
    required this.storeId,
    required this.tillId,
  });

  @override
  List<Object> get props => [storeId, tillId];
}

class SearchStores extends StoresEvent {
  final String query;

  const SearchStores(this.query);

  @override
  List<Object> get props => [query];
}

class FilterStoresByRegion extends StoresEvent {
  final String? region;

  const FilterStoresByRegion(this.region);

  @override
  List<Object?> get props => [region];
}
