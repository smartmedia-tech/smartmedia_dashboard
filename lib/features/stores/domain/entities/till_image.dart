import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TillImage extends Equatable {
  final String id;
  final String imageUrl;
  final DateTime timestamp;
  final String location;
  final String uploadedBy;
  final GeoPoint? geoPoint;
  final String? campaignId;
  final String? campaignName;
  final bool isOccupiedImage;

  const TillImage({
    required this.id,
    required this.imageUrl,
    required this.timestamp,
    required this.location,
    required this.uploadedBy,
    this.geoPoint,
    this.campaignId,
    this.campaignName,
    this.isOccupiedImage = false,
  });

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        timestamp,
        location,
        uploadedBy,
        geoPoint,
        campaignId,
        campaignName,
        isOccupiedImage,
      ];

  TillImage copyWith({
    String? id,
    String? imageUrl,
    DateTime? timestamp,
    String? location,
    String? uploadedBy,
    GeoPoint? geoPoint,
    String? campaignId,
    String? campaignName,
    bool? isOccupiedImage,
  }) {
    return TillImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      geoPoint: geoPoint ?? this.geoPoint,
      campaignId: campaignId ?? this.campaignId,
      campaignName: campaignName ?? this.campaignName,
      isOccupiedImage: isOccupiedImage ?? this.isOccupiedImage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'uploadedBy': uploadedBy,
      'geoPoint': geoPoint,
      'campaignId': campaignId,
      'campaignName': campaignName,
      'isOccupiedImage': isOccupiedImage,
    };
  }

  factory TillImage.fromMap(Map<String, dynamic> map) {
    return TillImage(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'] ?? 'Unknown Location',
      uploadedBy: map['uploadedBy'] ?? 'Unknown User',
      geoPoint: map['geoPoint'],
      campaignId: map['campaignId'],
      campaignName: map['campaignName'],
      isOccupiedImage: map['isOccupiedImage'] ?? false,
    );
  }
}
