import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import '../../domain/entities/report.dart';

class ReportModel extends Report {
  ReportModel({
    required super.id,
    required super.campaign,
    required super.stores,
    required super.generatedAt,
    required super.status,
    required super.metrics,
  });

  Map<String, dynamic> toMap() {
    return {
      'campaignId': campaign.id,
      'campaignName': campaign.name,
      'storeIds': stores.map((store) => store.id).toList(),
      'generatedAt': Timestamp.fromDate(generatedAt),
      'status': status.index,
      'metrics': {
        'totalStores': metrics.totalStores,
        'totalTills': metrics.totalTills,
        'occupiedTills': metrics.occupiedTills,
        'availableTills': metrics.availableTills,
        'storesWithImages': metrics.storesWithImages,
        'tillsWithImages': metrics.tillsWithImages,
        'occupancyRate': metrics.occupancyRate,
      },
    };
  }

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final metricsData = data['metrics'] as Map<String, dynamic>;

    return ReportModel(
      id: doc.id,
      campaign: Campaign(
        id: data['campaignId'],
        name: data['campaignName'],
        description: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
      stores: const[], 
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      status: ReportStatus.values[data['status'] ?? 0],
      metrics: ReportMetrics(
        totalStores: metricsData['totalStores'] ?? 0,
        totalTills: metricsData['totalTills'] ?? 0,
        occupiedTills: metricsData['occupiedTills'] ?? 0,
        availableTills: metricsData['availableTills'] ?? 0,
        storesWithImages: metricsData['storesWithImages'] ?? 0,
        tillsWithImages: metricsData['tillsWithImages'] ?? 0,
        occupancyRate: (metricsData['occupancyRate'] ?? 0.0).toDouble(),
      ),
    );
  }

  factory ReportModel.fromEntity(Report report) {
    return ReportModel(
      id: report.id,
      campaign: report.campaign,
      stores: report.stores,
      generatedAt: report.generatedAt,
      status: report.status,
      metrics: report.metrics,
    );
  }
}
