import 'package:trgtz/api/api.service.dart';

class AlertApiService extends ApiBaseService {
  AlertApiService() {
    controller = 'alerts';
  }
  
  Future<ApiResponse> getAlertTypes() => get('/types');
}
