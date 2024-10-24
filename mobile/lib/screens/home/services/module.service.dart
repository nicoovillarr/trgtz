import 'dart:io';

import 'package:redux/redux.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';

class ModuleService {
  static final GoalService _goalService = GoalService();
  static final UserService _userService = UserService();

  static Future<Goal> createGoal(Goal goal) async =>
      (await _goalService.createGoal([goal])).first;

  static Future deleteGoal(String id) async => _goalService.deleteGoal(id);

  static Future updateUser(User user, Store<ApplicationState> store) async {
    dynamic response = await _userService.patchUser(user);
    store.dispatch(SetUserAction(user: response['user']));
    store.dispatch(SetGoalsAction(goals: response['goals']));
  }

  static Future changePassword(
      String oldPassword, String newPassword) async => await _userService.changePassword(oldPassword, newPassword);

  static Future setProfileImage(File image) async =>
      await _userService.setProfileImage(image);

  static Future validateEmail() async => await _userService.validateEmail();
}
