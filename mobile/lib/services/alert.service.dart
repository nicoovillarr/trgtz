import 'package:trgtz/api/alert_api.service.dart';
import 'package:trgtz/api/index.dart';
import 'package:trgtz/core/exceptions/api_exception.dart';

class AlertService {
  final AlertApiService _alertApiService = AlertApiService();

  Future<Map<String, String>> getAlertTypes() async {
    ApiResponse response = await _alertApiService.getAlertTypes();
    if (response.status) {
      return Map<String, String>.from(response.content);
    } else {
      throw ApiException(response.content);
    }
  }
}
