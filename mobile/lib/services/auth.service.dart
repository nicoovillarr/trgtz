import 'package:trgtz/api/index.dart';
import 'package:trgtz/core/exceptions/index.dart';
import 'package:trgtz/core/exceptions/sso_login_exception.dart';

class AuthService {
  final AuthApiService _authApiService = AuthApiService();

  Future<Map<String, dynamic>> login(
      String email, String password, Map<String, dynamic> deviceInfo) async {
    ApiResponse response = await _authApiService.login(
      email,
      deviceInfo,
      password: password,
    );
    if (response.status) {
      return response.content;
    } else {
      throw AppException(response.content);
    }
  }

  Future<Map<String, dynamic>> signup(String firstName, String email,
      String password, Map<String, dynamic> deviceInfo) async {
    ApiResponse response = await _authApiService.signup(
      email,
      firstName,
      deviceInfo,
      password: password,
    );
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

  Future<Map<String, dynamic>> googleSignIn(
      String idToken, String email, Map<String, dynamic> deviceInfo) async {
    ApiResponse response =
        await _authApiService.googleSignIn(idToken, email, deviceInfo);
    if (response.status) {
      return response.content;
    } else if (response.statusCode == 401) {
      throw SsoLoginException();
    } else {
      throw AppException(response.content);
    }
  }

  Future<bool> addAuthProvider(String provider, String token) async {
    ApiResponse response = await _authApiService.addAuthProvider(provider, token);
    return response.status;
  }
}
