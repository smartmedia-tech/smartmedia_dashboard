import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';
import '../../domain/entities/report.dart';

class ReportModel extends Report {
  const ReportModel({
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
      // Only store store IDs in the report model to keep it lean.
      // Full store objects are not typically embedded for performance and normalization.
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
      // You might want to embed basic campaign details if not fetching full campaign later
      'campaignDescription': campaign.description,
      'campaignStartDate': campaign.startDate,
      'campaignEndDate': campaign.endDate,
      'campaignClientId': campaign.clientId,
      'campaignClientName': campaign.clientName,
      'campaignClientLogoUrl': campaign.clientLogoUrl,
      'campaignStatus': campaign.status.index,
    };
  }

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final metricsData = data['metrics'] as Map<String, dynamic>;

    return ReportModel(
      id: doc.id,
      campaign: Campaign(
        // Reconstruct basic Campaign object from embedded data
        id: data['campaignId'] ?? '',
        name: data['campaignName'] ?? '',
        description: data['campaignDescription'] ?? '',
        clientId: data['campaignClientId'] ?? '',
        clientLogoUrl: data['campaignClientLogoUrl'],
        clientName: data['campaignClientName'],
        startDate: (data['campaignStartDate'] as Timestamp?)?.toDate() ??
            DateTime(2000), // Default date if null
        endDate: (data['campaignEndDate'] as Timestamp?)?.toDate() ??
            DateTime(2000), // Default date if null
        status: CampaignStatus
            .values[data['campaignStatus'] ?? CampaignStatus.draft.index],
      ),
      // Stores are not embedded in the report document directly.
      // They will be fetched separately if needed for detailed display.
      stores: const [],
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
