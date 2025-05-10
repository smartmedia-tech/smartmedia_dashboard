import 'dart:io';
import 'package:smartmedia_campaign_manager/features/campaign/domain/repositories/campaign_repository.dart';

class UploadCampaignImage {
  final CampaignRepository repository;

  UploadCampaignImage(this.repository);

  /// Uploads an image for a campaign and returns the download URL
  ///
  /// [campaignId] - The ID of the campaign. If this is a new campaign, provide a temporary ID.
  /// [imageFile] - The image file to upload
  Future<String> call(String campaignId, File imageFile) async {
    return await repository.uploadCampaignImage(campaignId, imageFile);
  }
}
