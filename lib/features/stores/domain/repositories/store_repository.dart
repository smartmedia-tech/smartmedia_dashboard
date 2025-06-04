import 'dart:io';

import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

abstract class StoreRepository {
  Stream<List<Store>> getStores();
  Future<Store?> getStore(String storeId);
  Future<void> addStore({
    required String name,
    required String region,
    required String siteNumber,
    required int tillCount,
    String? imageUrl,
    String? id,
  });
  Future<List<Store>> getStoresWithCampaign(String campaignId);
  Future<String> uploadStoreImage(String storeId, File imageFile);

  Future<void> updateStore(Store store);
  Future<void> deleteStore(String storeId);
  Future<void> updateTillStatus({
    required String storeId,
    required String tillId,
    required bool isOccupied,
  });
  Future<String> uploadTillImage(
    String storeId,
    String tillId,
    File imageFile, {
    String? fileName,
  });
  Future<void> updateTillWithImage({
    required String storeId,
    required String tillId,
    required File imageFile,
  });
  Future<List<String>> fetchTillImages({
    required String storeId,
    required String tillId,
  });
  Future<List<String>> getUniqueRegions();
}
