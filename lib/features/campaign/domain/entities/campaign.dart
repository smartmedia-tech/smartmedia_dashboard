// lib/features/campaign/domain/entities/campaign.dart
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_deployment.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_image.dart';
import 'package:smartmedia_campaign_manager/features/campaign/data/models/campaign_model.dart'; // Import CampaignModel

class Campaign extends CampaignEntity {
  final String _id;
  final String _name;
  final String _description;
  final String _clientId;
  final String? _clientLogoUrl;
  final String? _clientName;
  final DateTime _startDate;
  final DateTime _endDate;
  final List<String> _storeIds;
  final List<String>? _imageUrls;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  final List<Store>? _stores;
  final CampaignStatus _status;
  final List<CampaignDeployment> _deployments;
  final List<TillImage>? _occupiedTillImages;

  Campaign({
    required String id,
    required String name,
    required String description,
    required String clientId,
    String? clientLogoUrl,
    String? clientName,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? storeIds,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Store>? stores,
    required CampaignStatus status,
    List<CampaignDeployment>? deployments,
    List<TillImage>? occupiedTillImages,
  })  : _id = id,
        _name = name,
        _description = description,
        _clientId = clientId,
        _clientLogoUrl = clientLogoUrl,
        _clientName = clientName,
        _startDate = startDate,
        _endDate = endDate,
        _storeIds = storeIds ?? [],
        _imageUrls = imageUrls,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _stores = stores,
        _status = status,
        _deployments = deployments ?? [],
        _occupiedTillImages = occupiedTillImages;

  // New factory constructor to create Campaign from CampaignModel
  factory Campaign.fromCampaignModel(CampaignModel model) {
    return Campaign(
      id: model.id,
      name: model.name,
      description: model.description,
      clientId: model.clientId,
      clientLogoUrl: model.clientLogoUrl,
      clientName: model.clientName,
      startDate: model.startDate,
      endDate: model.endDate,
      storeIds: model.storeIds,
      imageUrls: model.imageUrls,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      stores: model.stores,
      occupiedTillImages: model.occupiedTillImages,
      status: model.status,
      deployments: model.deployments,
    );
  }

  @override
  String get id => _id;
  @override
  String get name => _name;
  @override
  String get description => _description;
  @override
  String get clientId => _clientId;
  @override
  String? get clientLogoUrl => _clientLogoUrl;
  @override
  String? get clientName => _clientName;
  @override
  DateTime get startDate => _startDate;
  @override
  DateTime get endDate => _endDate;
  @override
  List<String> get storeIds => _storeIds;
  @override
  List<String>? get imageUrls => _imageUrls;
  @override
  DateTime? get createdAt => _createdAt;
  @override
  DateTime? get updatedAt => _updatedAt;
  @override
  List<Store>? get stores => _stores;
  @override
  CampaignStatus get status => _status;
  @override
  List<CampaignDeployment> get deployments => _deployments;
  @override
  List<TillImage>? get occupiedTillImages => _occupiedTillImages;
}
