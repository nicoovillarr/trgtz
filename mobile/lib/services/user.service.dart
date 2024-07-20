import 'package:trgtz/api/index.dart';
import 'package:trgtz/core/exceptions/index.dart';
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
      result['friends'] = (content['friends'] as List)
          .map((e) => Friendship.fromJson(e))
          .toList();
      result['alerts'] =
          (content['alerts'] as List).map((e) => Alert.fromJson(e)).toList();
      return result;
    } else {
      throw AppException(response.content);
    }
  }

  Future<Map<String, dynamic>> patchUser(User user) async {
    ApiResponse response = await _userApiService.patchUser(user);
    if (response.status) {
      return getMe();
    } else {
      throw AppException(response.content);
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    ApiResponse response =
        await _userApiService.changePassword(oldPassword, newPassword);
    if (response.status) {
      return getMe();
    } else {
      throw AppException(response.content);
    }
  }

  Future<dynamic> answerFriendRequest(String requesterId, bool answer) async {
    ApiResponse response =
        await _userApiService.answerFriendRequest(requesterId, answer);
    if (response.status) {
      return response.content;
    } else {
      throw AppException(response.content);
    }
  }

  Future<dynamic> deleteFriend(String userId, Friendship friendship) async {
    ApiResponse response =
        await _userApiService.deleteFriend(userId, friendship);
    if (response.status) {
      return response.content;
    } else {
      throw AppException(response.content);
    }
  }

  Future<dynamic> addFriend(String code) async {
    ApiResponse response = await _userApiService.addFriend(code);
    if (response.status) {
      return response.content;
    } else {
      throw AppException(response.content);
    }
  }

  Future<List<Friendship>> getPendingFriendRequests() async {
    ApiResponse response = await _userApiService.getPendingFriendRequests();
    if (response.status) {
      return (response.content as List)
          .map((e) => Friendship.fromJson(e))
          .toList();
    } else {
      throw AppException(response.content);
    }
  }

  Future<List<Friendship>> getFriends() async {
    ApiResponse response = await _userApiService.getFriends();
    if (response.status) {
      return (response.content as List)
          .map((e) => Friendship.fromJson(e))
          .toList();
    } else {
      throw AppException(response.content);
    }
  }
}
