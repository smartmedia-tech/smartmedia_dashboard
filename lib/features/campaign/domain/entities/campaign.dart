import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_deployment.dart';

class Campaign {
  final String id;
  final String name;
  final String? clientLogoUrl;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final CampaignStatus status;
  final List<CampaignDeployment> deployments;

  Campaign({
    required this.id,
    required this.name,
    this.clientLogoUrl,
    required this.description,
    required this.startDate,
    required this.endDate,
     this.status = CampaignStatus.draft,
    this.deployments = const [],
  });

  Campaign copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    CampaignStatus? status,
    String? clientLogoUrl,
    List<CampaignDeployment>? deployments,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      clientLogoUrl: clientLogoUrl ?? this.clientLogoUrl,
       deployments: deployments ?? this.deployments,
    );
  }
}

enum CampaignStatus { draft, active, paused, completed, archived }
