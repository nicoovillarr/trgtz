import 'package:trgtz/api/index.dart';
import 'package:trgtz/core/exceptions/index.dart';

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
      throw ApiException(response.content);
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
      throw ApiException(response.content);
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
    } else if (response.statusCode == 409) {
      throw SsoLoginException();
    } else {
      throw ApiException(response.content);
    }
  }

  Future<bool> addAuthProvider(String provider, String token) async {
    ApiResponse response = await _authApiService.addAuthProvider(provider, token);
    return response.status;
  }

  Future sendResetLink(String email) async {
    ApiResponse response = await _authApiService.sendResetLink(email);
    if (!response.status) {
      throw ApiException(response.content);
    }
  }
}
