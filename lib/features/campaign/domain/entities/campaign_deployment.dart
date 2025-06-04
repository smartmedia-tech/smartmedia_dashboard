class CampaignDeployment {
  final String id;
  final String storeId;
  final String storeName;
  final String tillId;
  final int tillNumber;
  final DateTime deployedAt;
  final String? imageUrl;
  final CampaignDeploymentStatus status;

  const CampaignDeployment({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.tillId,
    required this.tillNumber,
    required this.deployedAt,
    this.imageUrl,
    this.status = CampaignDeploymentStatus.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'storeName': storeName,
      'tillId': tillId,
      'tillNumber': tillNumber,
      'deployedAt': deployedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'status': status.index,
    };
  }

  factory CampaignDeployment.fromMap(Map<String, dynamic> map) {
    return CampaignDeployment(
      id: map['id'] ?? '',
      storeId: map['storeId'] ?? '',
      storeName: map['storeName'] ?? '',
      tillId: map['tillId'] ?? '',
      tillNumber: map['tillNumber'] ?? 0,
      deployedAt: DateTime.parse(map['deployedAt']),
      imageUrl: map['imageUrl'],
      status: CampaignDeploymentStatus.values[map['status'] ?? 0],
    );
  }

  CampaignDeployment copyWith({
    String? id,
    String? storeId,
    String? storeName,
    String? tillId,
    int? tillNumber,
    DateTime? deployedAt,
    String? imageUrl,
    CampaignDeploymentStatus? status,
  }) {
    return CampaignDeployment(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      tillId: tillId ?? this.tillId,
      tillNumber: tillNumber ?? this.tillNumber,
      deployedAt: deployedAt ?? this.deployedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }
}

enum CampaignDeploymentStatus { active, inactive, completed }
