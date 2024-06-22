import 'package:trgtz/api/goals_api.service.dart';
import 'package:trgtz/api/index.dart';
import 'package:trgtz/models/index.dart';

class ModuleService {
  final AuthApiService _authApiService = AuthApiService();
  final GoalsApiService _goalsApiService = GoalsApiService();

  Future<ApiResponse> login(String email, String password) async =>
      await _authApiService.login(email, password);

  Future<ApiResponse> signup(
          String firstName, String email, String password) async =>
      await _authApiService.signup(firstName, email, password);

  Future<ApiResponse> saveGoals(List<Goal> goals) async =>
      await _goalsApiService.createGoals(goals);
}
