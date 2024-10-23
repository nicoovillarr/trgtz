import 'package:trgtz/api/api.service.dart';

class ReportApiService extends ApiBaseService {
  ReportApiService() {
    controller = 'reports';
  }

  Future<ApiResponse> createReport(String entityType, String entityId,
          String category, String reason) async =>
      post('', {
        'entityType': entityType,
        'entityId': entityId,
        'category': category,
        'reason': reason,
      });

  Future<ApiResponse> resolveReport(
          String reportId, String status, String resolution) async =>
      put(
        '/$reportId',
        {
          'status': status,
          'resolution': resolution,
        },
      );

  Future<ApiResponse> getReports() async => get('');

  Future<ApiResponse> getReportById(String id) async => get(id);

  Future<ApiResponse> getAdminReports() async => get('', params: {
        'showAll': true.toString(),
      });
}
