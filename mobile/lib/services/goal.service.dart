import 'package:trgtz/api/index.dart';
import 'package:trgtz/models/goal.dart';
import 'package:trgtz/store/local_storage.dart';
import 'package:trgtz/utils.dart';

class GoalService {
  final GoalsApiService _goalsApiService = GoalsApiService();

  Future<List<Goal>> getGoals() async {
    final bool hasToken = await Utils.hasToken();
    if (hasToken) {
      ApiResponse response = await _goalsApiService.getGoals();
      if (response.status) {
        return response.content
            .map<Goal>((goal) => Goal.fromJson(goal))
            .toList();
      } else {
        throw Exception(response.content['message']);
      }
    } else {
      return await LocalStorage.getSavedGoals();
    }
  }

  Future<Goal> getGoalById(String id) async {
    final bool hasToken = await Utils.hasToken();
    if (hasToken) {
      ApiResponse response = await _goalsApiService.getGoalById(id);
      if (response.status) {
        return Goal.fromJson(response.content);
      } else {
        throw Exception(response.content['message']);
      }
    } else {
      return await LocalStorage.getSavedGoals().then((goals) {
        return goals.firstWhere((goal) => goal.id == id);
      });
    }
  }

  Future<List<Goal>> createGoal(List<Goal> goals) async {
    final bool hasToken = await Utils.hasToken();
    if (hasToken) {
      ApiResponse response = await _goalsApiService.createGoals(goals);
      if (response.status) {
        return (response.content as List).map((e) => Goal.fromJson(e)).toList();
      } else {
        throw Exception(response.content['message']);
      }
    } else {
      return await LocalStorage.saveGoals(goals);
    }
  }
}
