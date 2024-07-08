import 'package:trgtz/api/index.dart';
import 'package:trgtz/models/index.dart';

class UserApiService extends ApiBaseService {
  UserApiService() {
    controller = 'users';
  }

  Future<ApiResponse> getMe() async => await get('');

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
}
