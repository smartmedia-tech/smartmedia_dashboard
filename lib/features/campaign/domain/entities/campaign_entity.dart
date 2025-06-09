// lib/features/campaign/domain/entities/campaign_entity.dart
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_deployment.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_image.dart';

import '../../../stores/domain/entities/till_model.dart';

abstract class CampaignEntity {
  String get id;
  String get name;
  String get description;
  String get clientId;
  String? get clientLogoUrl;
  String? get clientName;
  DateTime get startDate;
  DateTime get endDate;
  List<String> get storeIds;
  List<String>? get imageUrls;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  List<Store>? get stores;
  CampaignStatus get status; // <--- This was added
  List<CampaignDeployment> get deployments; // <--- This was added
  List<TillImage>? get occupiedTillImages;
  Duration get duration => endDate.difference(startDate);
  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isCompleted => DateTime.now().isAfter(endDate);
  double get progressPercentage {
    final total = duration.inDays;
    final elapsed = DateTime.now().difference(startDate).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  List<Store> get populatedStores => stores ?? [];

  int get totalStores => populatedStores.length;

  int get totalTills =>
      populatedStores.fold(0, (sum, store) => sum + store.totalTills);

  int get occupiedTills =>
      populatedStores.fold(0, (sum, store) => sum + store.occupiedTillsCount);

  int get availableTills =>
      populatedStores.fold(0, (sum, store) => sum + store.availableTillsCount);

  double get occupancyRate => totalTills > 0 ? occupiedTills / totalTills : 0.0;

  List<Till> get allOccupiedTills {
    return populatedStores.expand((store) => store.occupiedTills).toList();
  }

  List<String> get allTillImages {
    return populatedStores
        .expand((store) => store.tills)
        .expand((till) => till.images)
        .map((image) => image.imageUrl)
        .toList();
  }

  List<TillImage> get allTillImageObjects {
    return populatedStores
        .expand((store) => store.tills)
        .expand((till) => till.images)
        .toList();
  }

  Map<String, List<Store>> get storesByRegion {
    final Map<String, List<Store>> regionMap = {};
    for (final store in populatedStores) {
      regionMap.putIfAbsent(store.region, () => []).add(store);
    }
    return regionMap;
  }
}

enum CampaignStatus { draft, active, paused, completed, archived }
