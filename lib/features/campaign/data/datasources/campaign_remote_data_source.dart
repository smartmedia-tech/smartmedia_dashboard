import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign_model.dart';

class CampaignRemoteDataSource {
  final FirebaseFirestore firestore;
  CampaignRemoteDataSource(this.firestore);

  Future<void> createCampaign(CampaignModel campaign) async {
    await firestore.collection('campaigns').add(campaign.toMap());
  }

  Future<List<CampaignModel>> getCampaigns() async {
    final snapshot = await firestore.collection('campaigns').get();
    return snapshot.docs
        .map((doc) => CampaignModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
