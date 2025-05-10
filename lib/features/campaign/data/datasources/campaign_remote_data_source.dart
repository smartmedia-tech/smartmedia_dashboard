import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import '../models/campaign_model.dart';

import 'package:firebase_storage/firebase_storage.dart';

class CampaignRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage _storage;
  CampaignRemoteDataSource(this.firestore, this._storage);

  Future<String> createCampaign(CampaignModel campaign) async {
    final doc = await firestore.collection('campaigns').add(campaign.toMap());
    return doc.id;
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
    return snapshot.docs
        .map((doc) =>
            CampaignModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<String> uploadCampaignImage(String storeId, File imageFile) async {
    final ref = _storage.ref().child('campaign_images/$storeId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<CampaignModel> getCampaign(String id) async {
    final doc = await firestore.collection('campaigns').doc(id).get();
    if (!doc.exists) throw Exception('Campaign not found');
    return CampaignModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> updateCampaign(CampaignModel campaign) async {
    await firestore
        .collection('campaigns')
        .doc(campaign.id)
        .update(campaign.toMap());
  }

  Future<void> deleteCampaign(String id) async {
    await firestore.collection('campaigns').doc(id).delete();
  }

  Future<void> changeCampaignStatus(String id, CampaignStatus status) async {
    await firestore.collection('campaigns').doc(id).update({
      'status': status.index,
    });
  }
}
