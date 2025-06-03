import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class GetReportsUseCase {
  final ReportsRepository _repository;

  GetReportsUseCase(this._repository);

  Future<List<Report>> call() async {
    return await _repository.getReports();
  }
}
