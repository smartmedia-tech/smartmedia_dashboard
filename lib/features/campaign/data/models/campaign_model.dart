import '../../domain/entities/campaign.dart';

class CampaignModel extends Campaign {
  CampaignModel({
    required super.id,
    required super.name,
    required super.description,
    required super.startDate,
    required super.endDate,
    super.clientLogoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'clientLogoUrl': clientLogoUrl
    };
  }

  factory CampaignModel.fromMap(String id, Map<String, dynamic> map) {
    return CampaignModel(
      id: id,
      name: map['name'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
       clientLogoUrl: map['clientLogoUrl'],
    );
  }
}
