import 'package:redux/redux.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';

class ModuleService {
  static final _userService = UserService();

  static Future updateUser(User user, Store<AppState> store) async {
    dynamic response = await _userService.patchUser(user);
    store.dispatch(SetUserAction(user: response['user']));
    store.dispatch(SetGoalsAction(goals: response['goals']));
  }

  static Future changePassword(
      String oldPassword, String newPassword, Store<AppState> store) async {
    dynamic response =
        await _userService.changePassword(oldPassword, newPassword);
    store.dispatch(SetUserAction(user: response['user']));
    store.dispatch(SetGoalsAction(goals: response['goals']));
  }
}
