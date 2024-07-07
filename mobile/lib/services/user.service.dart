import 'package:trgtz/api/index.dart';
import 'package:trgtz/models/index.dart';

class UserService {
  final UserApiService _userApiService = UserApiService();

  Future<Map<String, dynamic>> getMe() async {
    ApiResponse response = await _userApiService.getMe();
    if (response.status) {
      final dynamic content = response.content;
      Map<String, dynamic> result = {};
      result['user'] = User.fromJson(content);
      result['goals'] =
          (content['goals'] as List).map((e) => Goal.fromJson(e)).toList();
      return result;
    } else {
      throw Exception(response.content['message']);
    }
  }

  Future<Map<String, dynamic>> patchUser(User user) async {
    ApiResponse response = await _userApiService.patchUser(user);
    if (response.status) {
      return getMe();
    } else {
      throw Exception(response.content['message']);
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    ApiResponse response =
        await _userApiService.changePassword(oldPassword, newPassword);
    if (response.status) {
      return getMe();
    } else {
      throw Exception(response.content['message']);
    }
  }
}
