import 'package:trgtz/api/index.dart';

class UserService {
  final UserApiService _userApiService = UserApiService();

  Future<dynamic> getMe() async {
    ApiResponse response = await _userApiService.getMe();
    if (response.status) {
      return response.content;
    } else {
      throw Exception(response.content['message']);
    }
  }
}
