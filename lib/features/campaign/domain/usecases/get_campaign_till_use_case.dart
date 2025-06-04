import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/repositories/store_repository.dart';

class GetCampaignTillUseCase  {
  final StoreRepository repository;

  GetCampaignTillUseCase(this.repository);


  Future<List<Store>> getStoresWithCampaign(String campaignId) =>
      repository.getStoresWithCampaign(campaignId);
}
