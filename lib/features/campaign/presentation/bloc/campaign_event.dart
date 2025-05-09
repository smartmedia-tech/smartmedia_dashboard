import '../../domain/entities/campaign.dart';

abstract class CampaignEvent {}

class LoadCampaigns extends CampaignEvent {}

class AddCampaign extends CampaignEvent {
  final Campaign campaign;
  AddCampaign(this.campaign);
}
