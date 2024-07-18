import 'package:trgtz/services/index.dart';
import 'package:trgtz/models/index.dart';

class ModuleService {
  final AuthService _authService = AuthService();
  final GoalService _goalsService = GoalService();
  final UserService _userService = UserService();

  Future<String> login(String email, String password,
          Map<String, dynamic> deviceInfo) async =>
      await _authService.login(email, password, deviceInfo);

  Future<String> signup(String firstName, String email, String password,
          Map<String, dynamic> deviceInfo) async =>
      await _authService.signup(firstName, email, password, deviceInfo);

  Future<List<Goal>> saveGoals(List<Goal> goals) async =>
      await _goalsService.createGoal(goals);

  Future<Map<String, dynamic>> getMe() async => await _userService.getMe();
}
