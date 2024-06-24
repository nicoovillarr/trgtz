import 'package:trgtz/api/index.dart';

class AuthService {
  final AuthApiService _authApiService = AuthApiService();

  Future<String> login(String email, String password) async {
    ApiResponse response = await _authApiService.login(email, password);
    if (response.status) {
      return response.content['token'];
    } else {
      throw Exception(response.content['message']);
    }
  }

  Future<String> signup(String firstName, String email, String password) async {
    ApiResponse response =
        await _authApiService.signup(firstName, email, password);
    if (response.status) {
      return response.content['token'];
    } else {
      throw Exception(response.content['message']);
    }
  }

  Future<bool> tick(String token) async {
    ApiResponse response = await _authApiService.tick(token);
    return response.status;
  }
}
