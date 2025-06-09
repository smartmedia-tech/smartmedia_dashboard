import 'package:equatable/equatable.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_image.dart';

class Till extends Equatable {
  final String id;
  final bool isOccupied;
  final int number;
  final List<TillImage> images;
  final DateTime? lastOccupiedTimestamp;
  final String? lastOccupiedBy;
  final String? lastOccupiedLocation;
  final String? currentCampaignId;
  final String? currentCampaignName;

  const Till({
    required this.id,
    required this.isOccupied,
    required this.number,
    this.images = const [],
    this.lastOccupiedTimestamp,
    this.lastOccupiedBy,
    this.lastOccupiedLocation,
    this.currentCampaignId,
    this.currentCampaignName,
  });

  // Helper getters
  String? get displayImage => images.isNotEmpty ? images.last.imageUrl : null;

  TillImage? get lastOccupationImage {
    try {
      return images.lastWhere((img) => img.isOccupiedImage);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        isOccupied,
        number,
        images,
        lastOccupiedTimestamp,
        lastOccupiedBy,
        lastOccupiedLocation,
        currentCampaignId,
        currentCampaignName,
      ];

  Till copyWith({
    String? id,
    bool? isOccupied,
    int? number,
    List<TillImage>? images,
    DateTime? lastOccupiedTimestamp,
    String? lastOccupiedBy,
    String? lastOccupiedLocation,
    String? currentCampaignId,
    String? currentCampaignName,
  }) {
    return Till(
      id: id ?? this.id,
      isOccupied: isOccupied ?? this.isOccupied,
      number: number ?? this.number,
      images: images ?? this.images,
      lastOccupiedTimestamp:
          lastOccupiedTimestamp ?? this.lastOccupiedTimestamp,
      lastOccupiedBy: lastOccupiedBy ?? this.lastOccupiedBy,
      lastOccupiedLocation: lastOccupiedLocation ?? this.lastOccupiedLocation,
      currentCampaignId: currentCampaignId ?? this.currentCampaignId,
      currentCampaignName: currentCampaignName ?? this.currentCampaignName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isOccupied': isOccupied,
      'number': number,
      'images': images.map((image) => image.toMap()).toList(),
      'lastOccupiedTimestamp': lastOccupiedTimestamp?.toIso8601String(),
      'lastOccupiedBy': lastOccupiedBy,
      'lastOccupiedLocation': lastOccupiedLocation,
      'currentCampaignId': currentCampaignId,
      'currentCampaignName': currentCampaignName,
    };
  }

  factory Till.fromMap(Map<String, dynamic> map) {
    return Till(
      id: map['id'] ?? '',
      isOccupied: map['isOccupied'] ?? false,
      number: map['number'] ?? 0,
      images: (map['images'] as List<dynamic>?)
              ?.map((e) => TillImage.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastOccupiedTimestamp: map['lastOccupiedTimestamp'] != null
          ? DateTime.tryParse(map['lastOccupiedTimestamp'])
          : null,
      lastOccupiedBy: map['lastOccupiedBy'],
      lastOccupiedLocation: map['lastOccupiedLocation'],
      currentCampaignId: map['currentCampaignId'],
      currentCampaignName: map['currentCampaignName'],
    );
  }
}
