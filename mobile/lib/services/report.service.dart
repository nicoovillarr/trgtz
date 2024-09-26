import 'package:trgtz/api/index.dart';
import 'package:trgtz/core/exceptions/index.dart';
import 'package:trgtz/models/index.dart';

class ReportService {
  final ReportApiService _reportApiService = ReportApiService();

  Future createReport(String entityType, String entityId, String category,
      String reason) async {
    ApiResponse response = await _reportApiService.createReport(
        entityType, entityId, category, reason);
    if (!response.status) {
      throw AppException(response.content);
    }
  }

  Future resolveReport(
      String reportId, String status, String resolution) async {
    ApiResponse response =
        await _reportApiService.resolveReport(reportId, status, resolution);
    if (!response.status) {
      throw AppException(response.content);
    }
  }

  Future getReports() async {
    ApiResponse response = await _reportApiService.getReports();
    if (response.status) {
      return (response.content as List)
          .map((report) => Report.fromJson(report))
          .toList();
    } else {
      throw AppException(response.content);
    }
  }

  Future getReportById(String id) async {
    ApiResponse response = await _reportApiService.getReportById(id);
    if (response.status) {
      return Report.fromJson(response.content);
    } else {
      throw AppException(response.content);
    }
  }
}
