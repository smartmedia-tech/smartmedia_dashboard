import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

import '../entities/report.dart';

abstract class ReportsRepository {
  Future<List<Store>> getStoresForCampaign(String campaignId);
  Future<Report> generateReport(Campaign campaign, List<Store> stores);
  Future<List<Report>> getReports();
  Future<void> saveReport(Report report);
  Future<void> deleteReport(String reportId);
}
