import 'package:trgtz/services/index.dart';
import 'package:trgtz/models/index.dart';

class ModuleService {
  final AuthService _authService = AuthService();
  final GoalService _goalsService = GoalService();
  final UserService _userService = UserService();

  Future<String> login(String email, String password) async =>
      await _authService.login(email, password);

  Future<String> signup(
          String firstName, String email, String password) async =>
      await _authService.signup(firstName, email, password);

  Future<List<Goal>> saveGoals(List<Goal> goals) async =>
      await _goalsService.createGoal(goals);

  Future<Map<String, dynamic>> getMe() async {
    Map<String, dynamic> result = {};
    final meResponse = await _userService.getMe();
    result['user'] = User.fromJson(meResponse);
    result['goals'] =
        (meResponse['goals'] as List).map((e) => Goal.fromJson(e)).toList();
    return result;
  }
}
