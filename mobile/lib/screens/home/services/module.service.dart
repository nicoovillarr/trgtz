import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';

class ModuleService {
  static final GoalService _goalService = GoalService();
  static final UserService _userService = UserService();

  static Future<Goal> createGoal(Goal goal) async =>
      (await _goalService.createGoal([goal])).first;

  static Future deleteGoal(String id) async => _goalService.deleteGoal(id);

  static Future answerFriendRequest(String requesterId, bool answer) async =>
      await _userService.answerFriendRequest(requesterId, answer);

  static Future deleteFriend(String userId, Friendship friendship) async =>
      await _userService.deleteFriend(userId, friendship);

  static Future addFriend(String code) async =>
      await _userService.addFriend(code);
}
