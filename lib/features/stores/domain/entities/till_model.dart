import 'package:equatable/equatable.dart';
class Till extends Equatable {
  final String id;
  final bool isOccupied;
  final int number;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? campaignId; // New field
  final String? campaignName; // New field
  final DateTime? campaignDeployedAt; // New field

  const Till({
    required this.id,
    required this.isOccupied,
    required this.number,
    this.imageUrl,
    this.imageUrls = const [],
    this.campaignId,
    this.campaignName,
    this.campaignDeployedAt,
  });

  @override
  List<Object?> get props => [
        id,
        isOccupied,
        number,
        imageUrl,
        imageUrls,
        campaignId,
        campaignName,
        campaignDeployedAt
      ];

  Till copyWith({
    String? id,
    bool? isOccupied,
    int? number,
    String? imageUrl,
    List<String>? imageUrls,
    String? campaignId,
    String? campaignName,
    DateTime? campaignDeployedAt,
  }) {
    return Till(
      id: id ?? this.id,
      isOccupied: isOccupied ?? this.isOccupied,
      number: number ?? this.number,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      campaignId: campaignId ?? this.campaignId,
      campaignName: campaignName ?? this.campaignName,
      campaignDeployedAt: campaignDeployedAt ?? this.campaignDeployedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isOccupied': isOccupied,
      'number': number,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'campaignId': campaignId,
      'campaignName': campaignName,
      'campaignDeployedAt': campaignDeployedAt?.toIso8601String(),
    };
  }

  factory Till.fromMap(Map<String, dynamic> map) {
    return Till(
      id: map['id'] ?? '',
      isOccupied: map['isOccupied'] ?? false,
      number: map['number'] ?? 0,
      imageUrl: map['imageUrl'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      campaignId: map['campaignId'],
      campaignName: map['campaignName'],
      campaignDeployedAt: map['campaignDeployedAt'] != null
          ? DateTime.parse(map['campaignDeployedAt'])
          : null,
    );
  }

  bool get hasCampaign => campaignId != null;
}
