class Campaign {
  final String id;
  final String name;
  final String? clientLogoUrl;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final CampaignStatus status;

  Campaign({
    required this.id,
    required this.name,
    this.clientLogoUrl,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.status = CampaignStatus.draft,
  });

  Campaign copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    CampaignStatus? status,
    String? clientLogoUrl,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      clientLogoUrl: clientLogoUrl ?? this.clientLogoUrl,
    );
  }
}

enum CampaignStatus { draft, active, paused, completed, archived }
