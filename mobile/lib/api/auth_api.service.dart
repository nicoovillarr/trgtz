import 'package:trgtz/api/api.service.dart';

class AuthApiService extends ApiBaseService {
  AuthApiService() {
    controller = 'auth';
  }

  Future<ApiResponse> login(
    String email,
    Map<String, dynamic> deviceInfo, {
    String? password = null,
    String provider = 'email',
  }) async =>
      await post('login', {
        'email': email,
        'password': password,
        'deviceInfo': deviceInfo,
      });

  Future<ApiResponse> signup(
          String email, String firstName, Map<String, dynamic> deviceInfo,
          {String? provider, String? password, String? photoUrl}) async =>
      await post('signup', {
        'firstName': firstName,
        'email': email,
        'password': password,
        'deviceInfo': deviceInfo,
        'provider': provider,
      });

  Future<ApiResponse> tick(String token) async => await get('tick');

  Future<ApiResponse> logout() async => await post('logout', {});

  Future<ApiResponse> googleSignIn(String idToken, String email,
          Map<String, dynamic> deviceInfo) async =>
      await post('google', {
        'idToken': idToken,
        'email': email,
        'deviceInfo': deviceInfo,
      });

 Future<ApiResponse> addAuthProvider(String provider, String token) async =>
      await put ('add-provider', {
        'provider': provider,
        'idToken': token,
      });

  Future<ApiResponse> sendResetLink(String email) async => await post('forgot-password', {
        'email': email,
      });
}
