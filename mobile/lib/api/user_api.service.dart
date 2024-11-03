import 'dart:io';

import 'package:trgtz/api/index.dart';
import 'package:trgtz/models/index.dart';

class UserApiService extends ApiBaseService {
  UserApiService() {
    controller = 'users';
  }

  Future<ApiResponse> patchUser(User user) async =>
      await patch('', user.toJson());

  Future<ApiResponse> changePassword(
          String oldPassword, String newPassword) async =>
      await patch('/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

  Future<ApiResponse> answerFriendRequest(String requesterId, bool answer) =>
      put(
        '/friend',
        {
          'requesterId': requesterId,
          'answer': answer,
        },
      );

  Future<ApiResponse> deleteFriend(String userId, Friendship friendship) =>
      delete('/friend/${friendship.otherUserId}', null);

  Future<ApiResponse> addFriend(String code) =>
      post('/friend', {'recipientId': code});

  Future<ApiResponse> getPendingFriendRequests(String userId) => get(
        '/$userId/friends',
        params: {
          'status': 'pending',
        },
      );

  Future<ApiResponse> setProfileImage(File image) =>
      uploadImage('profile-image', image);

  Future<ApiResponse> getUserGoals(String userId, {int? year}) =>
      get('/$userId/goals', params: {
        'year': year?.toString(),
      });

  Future<ApiResponse> getUserFriends(String userId) => get('/$userId/friends');

  Future<ApiResponse> getProfile(String userId) => get('/$userId');

  Future<ApiResponse> validateEmail() => get('/validate');

  Future<ApiResponse> sendFriendRequest(String userId) => post('/friend', {
        'recipientId': userId,
      });

  Future<ApiResponse> getUserSubscribedTypes() => get('/alerts/types');

  Future<ApiResponse> subscribeToAlertType(String type) =>
      put('/alerts/subscribe', {'type': type});

  Future<ApiResponse> unsubscribeToAlert(String type) =>
      put('/alerts/unsubscribe', {'type': type});
}
