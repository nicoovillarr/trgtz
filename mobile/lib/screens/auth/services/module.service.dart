import 'package:trgtz/services/index.dart';
import 'package:trgtz/models/index.dart';

class ModuleService {
  final AuthService _authService = AuthService();
  final GoalService _goalsService = GoalService();
  final UserService _userService = UserService();

  Future<Map<String, dynamic>> login(String email, String password,
          Map<String, dynamic> deviceInfo) async =>
      await _authService.login(email, password, deviceInfo);

  Future<Map<String, dynamic>> signup(String firstName, String email,
          String password, Map<String, dynamic> deviceInfo) async =>
      await _authService.signup(firstName, email, password, deviceInfo);

  Future<List<Goal>> saveGoals(List<Goal> goals) async =>
      await _goalsService.createGoal(goals);

  Future<Map<String, dynamic>> getUserProfile(String userId) async =>
      await _userService.getProfile(userId);

  Future<Map<String, dynamic>> googleSignIn(String idToken, String email,
          Map<String, dynamic> deviceInfo) async =>
      await _authService.googleSignIn(idToken, email, deviceInfo);
}
