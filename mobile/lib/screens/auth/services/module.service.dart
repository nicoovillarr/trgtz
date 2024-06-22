import 'package:trgtz/api/index.dart';

class ModuleService {
  final AuthApiService _authApiService = AuthApiService();

  Future<ApiResponse> login(String email, String password) async =>
      await _authApiService.login(email, password);

  Future<ApiResponse> signup(
          String firstName, String email, String password) async =>
      await _authApiService.signup(firstName, email, password);
}
