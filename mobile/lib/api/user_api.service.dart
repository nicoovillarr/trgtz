import 'package:trgtz/api/index.dart';

class UserApiService extends ApiBaseService {
  UserApiService() {
    controller = 'users';
  }

  Future<ApiResponse> getMe() async => await get('');
}
