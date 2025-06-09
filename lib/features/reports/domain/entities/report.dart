import 'package:equatable/equatable.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

class Report extends Equatable {
  final String id;
  final Campaign campaign;
  final List<Store>
      stores; // This list should hold the full Store objects for the report
  final DateTime generatedAt;
  final ReportStatus status;
  final ReportMetrics metrics;

  const Report({
    required this.id,
    required this.campaign,
    required this.stores,
    required this.generatedAt,
    required this.status,
    required this.metrics,
  });

  @override
  List<Object?> get props =>
      [id, campaign, stores, generatedAt, status, metrics];

  Report copyWith({
    String? id,
    Campaign? campaign,
    List<Store>? stores,
    DateTime? generatedAt,
    ReportStatus? status,
    ReportMetrics? metrics,
  }) {
    return Report(
      id: id ?? this.id,
      campaign: campaign ?? this.campaign,
      stores: stores ?? this.stores,
      generatedAt: generatedAt ?? this.generatedAt,
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
    );
  }
}

enum ReportStatus { generating, completed, failed }

class ReportMetrics extends Equatable {
  final int totalStores;
  final int totalTills;
  final int occupiedTills;
  final int availableTills;
  final int storesWithImages;
  final int tillsWithImages;
  final double occupancyRate;

  const ReportMetrics({
    required this.totalStores,
    required this.totalTills,
    required this.occupiedTills,
    required this.availableTills,
    required this.storesWithImages,
    required this.tillsWithImages,
    required this.occupancyRate,
  });

  @override
  List<Object?> get props => [
        totalStores,
        totalTills,
        occupiedTills,
        availableTills,
        storesWithImages,
        tillsWithImages,
        occupancyRate,
      ];
}
