// lib/features/campaign/data/datasources/campaign_remote_data_source.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_image.dart';

import '../../domain/entities/campaign_entity.dart'; // Import CampaignStatus
import '../models/campaign_model.dart';

class CampaignRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage _storage;

  CampaignRemoteDataSource(this.firestore, this._storage);

  // --- ADMIN-SPECIFIC CORE OPERATIONS ---

  Future<String> createCampaign(CampaignModel campaign) async {
    final doc =
        await firestore.collection('campaigns').add(campaign.toFirestore());
    return doc.id;
  }

  Future<void> updateCampaign(CampaignModel campaign) async {
    await firestore
        .collection('campaigns')
        .doc(campaign.id)
        .update(campaign.toFirestore());
  }

  Future<void> deleteCampaign(String id) async {
    await firestore.collection('campaigns').doc(id).delete();
  }

  Future<String> uploadCampaignImage(String campaignId, File imageFile) async {
    final ref = _storage.ref().child(
        'campaign_images/$campaignId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // --- ADD THIS METHOD ---
  Future<void> changeCampaignStatus(String id, CampaignStatus status) async {
    await firestore.collection('campaigns').doc(id).update({
      'status': status.index, // Store the enum's index
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  // --- END ADDED METHOD ---

  // --- DATA FETCHING AND ENRICHMENT ---

  Future<CampaignModel> getCampaign(String id) async {
    final doc = await firestore.collection('campaigns').doc(id).get();
    if (!doc.exists) throw Exception('Campaign not found');

    final campaign = CampaignModel.fromFirestore(doc);
    return await _enrichCampaignWithStoresAndTills(campaign);
  }

  Future<List<CampaignModel>> getCampaigns(
      {int limit = 10, String? lastId}) async {
    Query query = firestore
        .collection('campaigns')
        .orderBy('startDate', descending: true)
        .limit(limit);

    if (lastId != null) {
      final lastDoc = await firestore.collection('campaigns').doc(lastId).get();
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    final campaigns =
        snapshot.docs.map((doc) => CampaignModel.fromFirestore(doc)).toList();

    List<CampaignModel> enrichedCampaigns = [];
    for (var campaign in campaigns) {
      enrichedCampaigns.add(await _enrichCampaignWithStoresAndTills(campaign));
    }
    return enrichedCampaigns;
  }

  Future<List<CampaignModel>> getCampaignsWithStores() async {
    final campaigns = await getCampaigns();
    return campaigns;
  }

  Future<List<CampaignModel>> getActiveCampaignsWithStores() async {
    final now = DateTime.now();

    final snapshot = await firestore
        .collection('campaigns')
        .where('startDate', isLessThanOrEqualTo: now)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .get();

    final campaigns =
        snapshot.docs.map((doc) => CampaignModel.fromFirestore(doc)).toList();

    List<CampaignModel> enrichedCampaigns = [];
    for (var campaign in campaigns) {
      enrichedCampaigns.add(await _enrichCampaignWithStoresAndTills(campaign));
    }
    return enrichedCampaigns;
  }

  Future<List<CampaignModel>> getCampaignsForStore(String storeId) async {
    final campaignsByStoreIdsQuery = await firestore
        .collection('campaigns')
        .where('storeIds', arrayContains: storeId)
        .get();

    final List<CampaignModel> campaignsByStoreIds = campaignsByStoreIdsQuery
        .docs
        .map((doc) => CampaignModel.fromFirestore(doc))
        .toList();

    final store = await _getStoreById(storeId);
    final Set<String> campaignIdsWithOccupiedTills = {};

    if (store != null) {
      for (final till in store.tills) {
        if (till.currentCampaignId != null) {
          campaignIdsWithOccupiedTills.add(till.currentCampaignId!);
        }
      }
    }

    final Set<String> allMatchingCampaignIds = {};
    for (final campaign in campaignsByStoreIds) {
      allMatchingCampaignIds.add(campaign.id);
    }
    allMatchingCampaignIds.addAll(campaignIdsWithOccupiedTills);

    final List<CampaignModel> matchingAndEnrichedCampaigns = [];
    for (final campaignId in allMatchingCampaignIds) {
      final doc = await firestore.collection('campaigns').doc(campaignId).get();
      if (doc.exists) {
        final campaign = CampaignModel.fromFirestore(doc);
        matchingAndEnrichedCampaigns
            .add(await _enrichCampaignWithStoresAndTills(campaign));
      }
    }
    return matchingAndEnrichedCampaigns;
  }

  // --- HELPER METHODS ---

  Future<CampaignModel> _enrichCampaignWithStoresAndTills(
      CampaignModel campaign) async {
    final allStoreIds = await _getAllStoreIdsForCampaign(campaign);
    final stores = await _getStoresByIds(allStoreIds.toList());

    List<TillImage> occupiedTillImages = [];
    for (var store in stores) {
      for (var till in store.tills) {
        if (till.currentCampaignId == campaign.id) {
          occupiedTillImages.addAll(till.images);
        }
      }
    }
    return campaign.copyWith(
      stores: stores,
      occupiedTillImages: occupiedTillImages,
      // When enriching, status and deployments are already present from fromFirestore
      // or set as defaults, so no need to explicitly copy them again unless logic requires it.
    );
  }

  Future<Set<String>> _getAllStoreIdsForCampaign(CampaignModel campaign) async {
    final Set<String> allStoreIds = {...campaign.storeIds};

    final storesWithOccupiedTills =
        await _getStoresWithOccupiedTillsForCampaign(campaign.id);
    allStoreIds.addAll(storesWithOccupiedTills);

    return allStoreIds;
  }

  Future<List<String>> _getStoresWithOccupiedTillsForCampaign(
      String campaignId) async {
    final List<String> storeIds = [];
    final storesSnapshot = await firestore.collection('stores').get();

    for (final doc in storesSnapshot.docs) {
      final store = Store.fromFirestore(doc);
      final hasOccupiedTillForCampaign = store.tills.any(
        (till) => till.currentCampaignId == campaignId,
      );

      if (hasOccupiedTillForCampaign) {
        storeIds.add(store.id);
      }
    }
    return storeIds;
  }

  Future<List<Store>> _getStoresByIds(List<String> storeIds) async {
    if (storeIds.isEmpty) return [];

    final List<Store> allStores = [];
    const batchSize = 10;

    for (int i = 0; i < storeIds.length; i += batchSize) {
      final batch = storeIds.skip(i).take(batchSize).toList();

      final snapshot = await firestore
          .collection('stores')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      final stores =
          snapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();
      allStores.addAll(stores);
    }
    return allStores;
  }

  Future<Store?> _getStoreById(String storeId) async {
    try {
      final doc = await firestore.collection('stores').doc(storeId).get();
      if (doc.exists) {
        return Store.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching store $storeId: $e');
      return null;
    }
  }
}
