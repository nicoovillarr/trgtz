import 'package:mobile/api/api.service.dart';

class AuthApiService extends ApiBaseService {
  AuthApiService() {
    controller = 'auth';
  }

  Future<ApiResponse> login(String email, String password) async =>
      await post('login', {
        'email': email,
        'password': password,
      });

  Future<ApiResponse> signup(
          String firstName, String email, String password) async =>
      await post('signup', {
        'firstName': firstName,
        'email': email,
        'password': password,
      });
}
