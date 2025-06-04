import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_deployment.dart';

import '../../domain/entities/campaign.dart';
class CampaignModel extends Campaign {
  CampaignModel({
    required super.id,
    required super.name,
    required super.description,
    required super.startDate,
    required super.endDate,
    super.clientLogoUrl,
    super.status,
    super.deployments,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'clientLogoUrl': clientLogoUrl,
      'status': status.index,
      'deployments': deployments.map((d) => d.toMap()).toList(),
    };
  }

  factory CampaignModel.fromMap(String id, Map<String, dynamic> map) {
    List<CampaignDeployment> deploymentsList = [];
    if (map['deployments'] != null) {
      deploymentsList = List<CampaignDeployment>.from(
          (map['deployments'] as List)
              .map((x) => CampaignDeployment.fromMap(x)));
    }

    return CampaignModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      clientLogoUrl: map['clientLogoUrl'],
      status: CampaignStatus.values[map['status'] ?? 0],
      deployments: deploymentsList,
    );
  }
}
