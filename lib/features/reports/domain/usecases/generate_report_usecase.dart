import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';

import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class GenerateReportUseCase {
  final ReportsRepository _repository;

  GenerateReportUseCase(this._repository);

  Future<Report> call(Campaign campaign) async {
    final stores = await _repository.getStoresForCampaign(campaign.id);
    return await _repository.generateReport(campaign, stores);
  }
}
