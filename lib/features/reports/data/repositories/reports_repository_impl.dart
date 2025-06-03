import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/reports/data/models/report_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/report.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final FirebaseFirestore _firestore;

  ReportsRepositoryImpl(this._firestore);

 @override
  Future<List<Store>> getStoresForCampaign(String campaignId) async {
    try {
      // Query stores where at least one till has the specified campaignId
      final storesSnapshot = await _firestore
          .collection('stores')
          .where('tills', arrayContainsAny: [
        {'campaignId': campaignId}
      ]).get();

      // Filter stores and tills to only include relevant campaign data
      final stores = storesSnapshot.docs
          .map((doc) => Store.fromFirestore(doc))
          .where((store) =>
              store.tills.any((till) => till.campaignId == campaignId))
          .map((store) {
        // Create a copy of the store with only tills that have this campaign
        final relevantTills =
            store.tills.where((till) => till.campaignId == campaignId).toList();

        return store.copyWith(tills: relevantTills);
      }).toList();

      return stores;
    } catch (e) {
      throw Exception('Failed to get stores for campaign: $e');
    }
  }

  @override
  Future<Report> generateReport(Campaign campaign, List<Store> stores) async {
    try {
      final metrics = _calculateMetrics(stores);
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        campaign: campaign,
        stores: stores,
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
      await _firestore
          .collection('reports')
          .doc(report.id)
          .set(reportModel.toMap());
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

  ReportMetrics _calculateMetrics(List<Store> stores) {
    final totalStores = stores.length;
    final totalTills = stores.fold(0, (sum, store) => sum + store.totalTills);
    final occupiedTills =
        stores.fold(0, (sum, store) => sum + store.occupiedTills);
    final availableTills = totalTills - occupiedTills;
    final storesWithImages =
        stores.where((store) => store.imageUrl != null).length;
    final tillsWithImages = stores.fold(
      0,
      (sum, store) =>
          sum +
          store.tills
              .where(
                  (till) => till.imageUrl != null || till.imageUrls.isNotEmpty)
              .length,
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
