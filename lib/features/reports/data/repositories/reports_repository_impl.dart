import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/reports/data/models/report_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/report.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final FirebaseFirestore _firestore;

  ReportsRepositoryImpl(this._firestore);

  @override
  Future<List<Store>> getStoresForCampaign(String campaignId) async {
    try {
      // Fetch all stores and then filter client-side for tills with the campaignId.
      // Firestore's arrayContains is not ideal for deeply nested complex objects.
      final storesSnapshot = await _firestore.collection('stores').get();

      final List<Store> campaignStores = [];
      for (var doc in storesSnapshot.docs) {
        final store = Store.fromFirestore(doc);
        final relevantTills = store.tills
            .where((till) => till.currentCampaignId == campaignId)
            .toList();

        if (relevantTills.isNotEmpty) {
          // If the store has tills associated with this campaign,
          // create a copy of the store with only those relevant tills.
          campaignStores.add(store.copyWith(tills: relevantTills));
        }
      }
      return campaignStores;
    } catch (e) {
      throw Exception('Failed to get stores for campaign: $e');
    }
  }

  @override
  Future<Report> generateReport(Campaign campaign, List<Store> stores) async {
    try {
      final metrics = _calculateMetrics(campaign,
          stores); // Pass campaign to metrics for potential future use
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        campaign: campaign,
        stores:
            stores, // Stores are passed here for calculation, but not saved in report document
        generatedAt: DateTime.now(),
        status: ReportStatus.completed,
        metrics: metrics,
      );

      await saveReport(report);
      return report;
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  @override
  Future<List<Report>> getReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('generatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports: $e');
    }
  }

  @override
  Future<void> saveReport(Report report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      final data = reportModel.toMap();
      await _firestore.collection('reports').doc(report.id).set(data);
    } catch (e) {
      throw Exception('Failed to save report: $e');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // Pass campaign here to access campaign-specific properties if needed for metrics
  ReportMetrics _calculateMetrics(Campaign campaign, List<Store> stores) {
    final totalStores = stores.length;
    final totalTills = stores.fold(0, (sum, store) => sum + store.totalTills);

    // Filter tills specific to the campaign in this report
    final List<Till> campaignSpecificTills = stores
        .expand((store) => store.tills)
        .where((till) => till.currentCampaignId == campaign.id)
        .toList();

    final occupiedTills = campaignSpecificTills.length;
    final availableTills = totalTills - occupiedTills;

    final storesWithImages = stores
        .where((store) => store.imageUrl != null && store.imageUrl!.isNotEmpty)
        .length;
  
    final tillsWithImages = campaignSpecificTills.fold(
      0,
      (sum, till) => sum + (till.images.isNotEmpty == true ? 1 : 0),
    );

    final occupancyRate =
        totalTills > 0 ? (occupiedTills / totalTills) * 100 : 0.0;

    return ReportMetrics(
      totalStores: totalStores,
      totalTills: totalTills,
      occupiedTills: occupiedTills,
      availableTills: availableTills,
      storesWithImages: storesWithImages,
      tillsWithImages: tillsWithImages,
      occupancyRate: occupancyRate,
    );
  }
}
