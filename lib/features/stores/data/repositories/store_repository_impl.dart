import 'dart:io';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_data_source.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource _remoteDataSource;

  StoreRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<Store>> getStores() => _remoteDataSource.getStores();

  @override
  Future<Store?> getStore(String storeId) =>
      _remoteDataSource.getStore(storeId);

  @override
  Future<void> addStore({
    required String name,
    required String region,
    required String siteNumber,
    required int tillCount,
    String? imageUrl,
    String? id,
  }) async {
    await _remoteDataSource.addStore(
      name: name,
      region: region,
      siteNumber: siteNumber,
      tillCount: tillCount,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<String> uploadStoreImage(String storeId, File imageFile) async {
    return await _remoteDataSource.uploadStoreImage(storeId, imageFile);
  }

  @override
  Future<void> updateStore(Store store) => _remoteDataSource.updateStore(store);

  @override
  Future<void> deleteStore(String storeId) =>
      _remoteDataSource.deleteStore(storeId);

  @override
  Future<void> updateTillStatus({
    required String storeId,
    required String tillId,
    required bool isOccupied,
  }) =>
      _remoteDataSource.updateTillStatus(
        storeId: storeId,
        tillId: tillId,
        isOccupied: isOccupied,
      );

  @override
  Future<String> uploadTillImage(
    String storeId,
    String tillId,
    File imageFile, {
    String? fileName,
  }) =>
      _remoteDataSource.uploadTillImage(
        storeId,
        tillId,
        imageFile,
        fileName: fileName,
      );

  @override
  Future<void> updateTillWithImage({
    required String storeId,
    required String tillId,
    required File imageFile,
  }) =>
      _remoteDataSource.updateTillWithImage(
        storeId: storeId,
        tillId: tillId,
        imageFile: imageFile,
      );

  @override
  Future<List<String>> fetchTillImages({
    required String storeId,
    required String tillId,
  }) =>
      _remoteDataSource.fetchTillImages(
        storeId: storeId,
        tillId: tillId,
      );

  @override
  Future<List<String>> getUniqueRegions() =>
      _remoteDataSource.getUniqueRegions();
}
