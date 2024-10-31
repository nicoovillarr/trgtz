import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';

class ModuleService {
  static final UserService _userService = UserService();

  static Future deleteFriend(String userId, Friendship friendship) async =>
      await _userService.deleteFriend(userId, friendship);

  static Future addFriend(String code) async =>
      await _userService.addFriend(code);

  static Future answerFriendRequest(String requesterId, bool answer) async =>
      await _userService.answerFriendRequest(requesterId, answer);

  Future<List<Friendship>> getPendingFriendRequests(String userId) async =>
      await _userService.getPendingFriendRequests(userId);

  Future<List<Friendship>> getFriends(String userId) async =>
      await _userService.getFriends(userId);

  Future<User> getProfile(String userId) async {
    final Map<String, dynamic> profile = await _userService.getProfile(userId);
    return profile['user'];
  }
}
