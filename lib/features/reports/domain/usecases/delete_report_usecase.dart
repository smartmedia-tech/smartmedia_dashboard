import '../repositories/reports_repository.dart';

class DeleteReportUseCase {
  final ReportsRepository _repository;

  DeleteReportUseCase(this._repository);

  Future<void> call(String reportId) async {
    return await _repository.deleteReport(reportId);
  }
}
