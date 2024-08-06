import 'package:trgtz/api/index.dart';
import 'package:trgtz/core/exceptions/index.dart';

class AuthService {
  final AuthApiService _authApiService = AuthApiService();

  Future<Map<String, dynamic>> login(
      String email, String password, Map<String, dynamic> deviceInfo) async {
    ApiResponse response =
        await _authApiService.login(email, password, deviceInfo);
    if (response.status) {
      return response.content;
    } else {
      throw AppException(response.content);
    }
  }

  Future<Map<String, dynamic>> signup(String firstName, String email,
      String password, Map<String, dynamic> deviceInfo) async {
    ApiResponse response =
        await _authApiService.signup(firstName, email, password, deviceInfo);
    if (response.status) {
      return response.content;
    } else {
      throw AppException(response.content);
    }
  }

  Future<bool> tick(String token) async {
    ApiResponse response = await _authApiService.tick(token);
    return response.status;
  }

  Future logout() async => await _authApiService.logout();
}
