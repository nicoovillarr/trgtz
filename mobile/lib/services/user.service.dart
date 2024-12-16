import 'dart:io';

import 'package:trgtz/api/index.dart';
import 'package:trgtz/core/exceptions/index.dart';
import 'package:trgtz/models/index.dart';

class UserService {
  final UserApiService _userApiService = UserApiService();

  Future<Map<String, dynamic>> getProfile(String userId) async {
    ApiResponse response = await _userApiService.getProfile(userId);
    if (response.status) {
      final dynamic content = response.content;
      Map<String, dynamic> result = {};
      result['user'] = User.fromJson(content);
      result['goals'] = content.containsKey('goals')
          ? (content['goals'] as List).map((e) => Goal.fromJson(e)).toList()
          : [];
      result['friends'] = content.containsKey('friends')
          ? (content['friends'] as List)
              .map((e) => Friendship.fromJson(e))
              .toList()
          : [];
      if (content.containsKey('alerts')) {
        result['alerts'] =
            (content['alerts'] as List).map((e) => Alert.fromJson(e)).toList();
      }
      return result;
    } else {
      throw ApiException(response.content);
    }
  }

  Future patchUser(User user) async {
    ApiResponse response = await _userApiService.patchUser(user);
    if (!response.status) {
      throw ApiException(response.content);
    }
  }

  Future changePassword(String oldPassword, String newPassword) async {
    ApiResponse response =
        await _userApiService.changePassword(oldPassword, newPassword);
    if (!response.status) {
      throw ApiException(response.content);
    }
  }

  Future<dynamic> answerFriendRequest(String requesterId, bool answer) async {
    ApiResponse response =
        await _userApiService.answerFriendRequest(requesterId, answer);
    if (response.status) {
      return response.content;
    } else {
      throw ApiException(response.content);
    }
  }

  Future<dynamic> deleteFriend(String userId, Friendship friendship) async {
    ApiResponse response =
        await _userApiService.deleteFriend(userId, friendship);
    if (response.status) {
      return response.content;
    } else {
      throw ApiException(response.content);
    }
  }

  Future<dynamic> addFriend(String code) async {
    ApiResponse response = await _userApiService.addFriend(code);
    if (response.status) {
      return response.content;
    } else {
      throw ApiException(response.content);
    }
  }

  Future<List<Friendship>> getPendingFriendRequests(String userId) async {
    ApiResponse response =
        await _userApiService.getPendingFriendRequests(userId);
    if (response.status) {
      return (response.content as List)
          .map((e) => Friendship.fromJson(e))
          .toList();
    } else {
      throw ApiException(response.content);
    }
  }

  Future<List<Friendship>> getFriends(String userId) async {
    ApiResponse response = await _userApiService.getUserFriends(userId);
    if (response.status) {
      return (response.content as List)
          .map((e) => Friendship.fromJson(e))
          .toList();
    } else {
      throw ApiException(response.content);
    }
  }

  Future setProfileImage(File image) async {
    ApiResponse response = await _userApiService.setProfileImage(image);
    if (!response.status) {
      throw ApiException(response.content);
    }
  }

  Future getUserGoals(String userId) async {
    ApiResponse response = await _userApiService.getUserGoals(userId);
    if (response.status) {
      return (response.content as List).map((e) => Goal.fromJson(e)).toList();
    } else {
      throw ApiException(response.content);
    }
  }

  Future getUserFriends(String userId) async {
    ApiResponse response = await _userApiService.getUserFriends(userId);
    if (response.status) {
      return (response.content as List)
          .map((e) => Friendship.fromJson(e))
          .toList();
    } else {
      throw ApiException(response.content);
    }
  }

  Future validateEmail() async {
    ApiResponse response = await _userApiService.validateEmail();
    if (!response.status) {
      throw ApiException(response.content);
    }
  }

  Future sendFriendRequest(String userId) async {
    ApiResponse response = await _userApiService.sendFriendRequest(userId);
    if (!response.status) {
      throw ApiException(response.content);
    }
  }

  Future<List<String>> getUserSubscribedTypes() async {
    ApiResponse response = await _userApiService.getUserSubscribedTypes();
    if (response.status) {
      return (response.content as List).map((e) => e.toString()).toList();
    } else {
      throw ApiException(response.content);
    }
  }

  Future subscribeToAlertType(String type) async {
    ApiResponse response = await _userApiService.subscribeToAlertType(type);
    if (!response.status) {
      throw ApiException(response.content);
    }
  }

  Future unsubscribeToAlertType(String type) async {
    ApiResponse response = await _userApiService.unsubscribeToAlert(type);
    if (!response.status) {
      throw ApiException(response.content);
    }
  }
}
