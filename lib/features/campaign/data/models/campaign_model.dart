// lib/features/campaign/data/models/campaign_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_deployment.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_image.dart';

class CampaignModel extends CampaignEntity {
  @override
  final String id;

  @override
  final String name;

  @override
  final String description;

  @override
  final String clientId;

  @override
  final String? clientLogoUrl;

  @override
  final String? clientName;

  @override
  final DateTime startDate;

  @override
  final DateTime endDate;

  @override
  final List<String> storeIds;

  @override
  final List<String>? imageUrls;

  @override
  final DateTime? createdAt;

  @override
  final DateTime? updatedAt;

  @override
  final List<Store>? stores;

  @override
  final List<TillImage>? occupiedTillImages;

  @override
  final CampaignStatus status;

  @override
  final List<CampaignDeployment> deployments;

  CampaignModel({
    required this.id,
    required this.name,
    required this.description,
    required this.clientId,
    this.clientLogoUrl,
    this.clientName,
    required this.startDate,
    required this.endDate,
    this.storeIds = const [],
    this.imageUrls,
    this.createdAt,
    this.updatedAt,
    this.stores,
    this.occupiedTillImages,
    required this.status,
    this.deployments = const [],
  });

  factory CampaignModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CampaignModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      clientId: data['clientId'] ?? '',
      clientLogoUrl: data['clientLogoUrl'],
      clientName: data['clientName'],
      startDate: _parseDate(data['startDate']),
      endDate: _parseDate(data['endDate']),
      storeIds: List<String>.from(data['storeIds'] ?? []),
      imageUrls: data['imageUrls'] != null
          ? List<String>.from(data['imageUrls'])
          : null,
      createdAt:
          data['createdAt'] != null ? _parseDate(data['createdAt']) : null,
      updatedAt:
          data['updatedAt'] != null ? _parseDate(data['updatedAt']) : null,
      stores: null,
      occupiedTillImages: null,
      status:
          CampaignStatus.values[data['status'] ?? CampaignStatus.draft.index],
      deployments: (data['deployments'] as List<dynamic>?)
              ?.map(
                  (d) => CampaignDeployment.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // New factory constructor to create CampaignModel from CampaignEntity
  factory CampaignModel.fromCampaignEntity(CampaignEntity entity) {
    return CampaignModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      clientId: entity.clientId,
      clientLogoUrl: entity.clientLogoUrl,
      clientName: entity.clientName,
      startDate: entity.startDate,
      endDate: entity.endDate,
      storeIds: entity.storeIds,
      imageUrls: entity.imageUrls,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      stores: entity
          .stores, // These might be null, which is fine for the model's initial state
      occupiedTillImages: entity.occupiedTillImages, // Same here
      status: entity.status,
      deployments: entity.deployments,
    );
  }

  // You can remove or keep the 'create' factory, it's not strictly necessary for this error
  // but if you have specific creation logic, it's fine.
  factory CampaignModel.create({
    required String id,
    required String name,
    required String description,
    String? clientId,
    String? clientLogoUrl,
    String? clientName,
    required DateTime startDate,
    required DateTime endDate,
    required CampaignStatus status,
    List<String>? storeIds,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Store>? stores,
    List<TillImage>? occupiedTillImages,
    List<CampaignDeployment>? deployments,
  }) {
    return CampaignModel(
      id: id,
      name: name,
      description: description,
      clientId: clientId ?? '',
      clientLogoUrl: clientLogoUrl,
      clientName: clientName,
      startDate: startDate,
      endDate: endDate,
      status: status,
      storeIds: storeIds ?? [],
      imageUrls: imageUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
      stores: stores,
      occupiedTillImages: occupiedTillImages,
      deployments: deployments ?? [],
    );
  }

  CampaignModel copyWith({
    String? id,
    String? name,
    String? description,
    String? clientId,
    String? clientLogoUrl,
    String? clientName,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? storeIds,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Store>? stores,
    List<TillImage>? occupiedTillImages,
    CampaignStatus? status,
    List<CampaignDeployment>? deployments,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      clientLogoUrl: clientLogoUrl ?? this.clientLogoUrl,
      clientName: clientName ?? this.clientName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      storeIds: storeIds ?? this.storeIds,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stores: stores ?? this.stores,
      occupiedTillImages: occupiedTillImages ?? this.occupiedTillImages,
      status: status ?? this.status,
      deployments: deployments ?? this.deployments,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'clientId': clientId,
      if (clientLogoUrl != null) 'clientLogoUrl': clientLogoUrl,
      if (clientName != null) 'clientName': clientName,
      'startDate': startDate,
      'endDate': endDate,
      'storeIds': storeIds,
      if (imageUrls != null) 'imageUrls': imageUrls,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': status.index,
      // Note: Deployments are typically handled in a separate subcollection
      // for better scalability and performance. Uncomment the line below
      // if you need to embed deployments directly in the campaign document:
      // if (deployments.isNotEmpty) 'deployments': deployments.map((d) => d.toMap()).toList(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) throw Exception('Date cannot be null');
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    throw Exception('Invalid date format: $value');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CampaignModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.clientId == clientId &&
        other.clientLogoUrl == clientLogoUrl &&
        other.clientName == clientName &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      clientId,
      clientLogoUrl,
      clientName,
      startDate,
      endDate,
      status,
    );
  }

  @override
  String toString() {
    return 'CampaignModel(id: $id, name: $name, status: $status, startDate: $startDate, endDate: $endDate)';
  }
}
