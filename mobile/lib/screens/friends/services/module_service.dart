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

  static Future<List<Friendship>> getPendingFriendRequests() async =>
      await _userService.getPendingFriendRequests();

  static Future<List<Friendship>> getFriends() async =>
      await _userService.getFriends();
}
