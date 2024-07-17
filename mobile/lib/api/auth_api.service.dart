import 'package:trgtz/api/api.service.dart';

class AuthApiService extends ApiBaseService {
  AuthApiService() {
    controller = 'auth';
  }

  Future<ApiResponse> login(String email, String password,
          Map<String, dynamic> deviceInfo) async =>
      await post('login', {
        'email': email,
        'password': password,
        'deviceInfo': deviceInfo,
      });

  Future<ApiResponse> signup(String firstName, String email, String password,
          Map<String, dynamic> deviceInfo) async =>
      await post('signup', {
        'firstName': firstName,
        'email': email,
        'password': password,
        'deviceInfo': deviceInfo,
      });

  Future<ApiResponse> tick(String token) async => await get('tick');
}
