import 'dart:io';

import 'package:redux/redux.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';

class ModuleService {
  static final _userService = UserService();

  static Future updateUser(User user, Store<ApplicationState> store) async {
    dynamic response = await _userService.patchUser(user);
    store.dispatch(SetUserAction(user: response['user']));
    store.dispatch(SetGoalsAction(goals: response['goals']));
  }

  static Future changePassword(
      String oldPassword, String newPassword, Store<ApplicationState> store) async {
    dynamic response =
        await _userService.changePassword(oldPassword, newPassword);
    store.dispatch(SetUserAction(user: response['user']));
    store.dispatch(SetGoalsAction(goals: response['goals']));
  }

  static Future setProfileImage(File image) async =>
      await _userService.setProfileImage(image);

  static Future getUserGoals(User user) async =>
      await _userService.getUserGoals(user.id);

  static Future getUserFriends(User user) async =>
      await _userService.getUserFriends(user.id);

  Future getProfile(String userId) async =>
      await _userService.getProfile(userId);
}
