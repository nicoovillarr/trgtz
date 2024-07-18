import 'package:trgtz/api/api.service.dart';

class SessionApiService extends ApiBaseService {
  SessionApiService() {
    controller = 'sessions';
  }

  Future<ApiResponse> updateFirebaseToken(String token) async =>
      await patch('firebase-token', {'firebaseToken': token});
}
