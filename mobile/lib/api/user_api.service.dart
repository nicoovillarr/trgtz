import 'package:trgtz/api/index.dart';

class UserApiService extends ApiBaseService {
  UserApiService() {
    controller = 'users';
  }

  Future<ApiResponse> getMe() async => await get('');

  Future<ApiResponse> answerFriendRequest(String requesterId, bool answer) =>
      put(
        '/friend-request',
        {
          'requesterId': requesterId,
          'answer': answer,
        },
      );
}
