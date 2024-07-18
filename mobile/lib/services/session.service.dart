import 'package:trgtz/api/index.dart';

class SessionService {
  final SessionApiService _sessionApiService = SessionApiService();

  Future<void> updateFirebaseToken(String token) async {
    await _sessionApiService.updateFirebaseToken(token);
  }
}
