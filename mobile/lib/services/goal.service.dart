import 'package:trgtz/api/index.dart';
import 'package:trgtz/models/index.dart';

class GoalService {
  final GoalsApiService _goalsApiService = GoalsApiService();

  Future<List<Goal>> getGoals() async {
    ApiResponse response = await _goalsApiService.getGoals();
    if (response.status) {
      return response.content.map<Goal>((goal) => Goal.fromJson(goal)).toList();
    } else {
      throw Exception(response.content['message']);
    }
  }

  Future<Goal> getGoalById(String id) async {
    ApiResponse response = await _goalsApiService.getGoalById(id);
    if (response.status) {
      return Goal.fromJson(response.content);
    } else {
      throw Exception(response.content['message']);
    }
  }

  Future<List<Goal>> createGoal(List<Goal> goals) async {
    ApiResponse response = await _goalsApiService.createGoals(goals);
    if (response.status) {
      return (response.content as List).map((e) => Goal.fromJson(e)).toList();
    } else {
      throw Exception(response.content['message']);
    }
  }

  Future deleteGoal(String id) async {
    ApiResponse response = await _goalsApiService.deleteGoal(id);
    if (!response.status) {
      throw Exception(response.content['message']);
    }
  }

  Future updateGoal(Goal goal) async {
    ApiResponse response = await _goalsApiService.updateGoal(goal);
    if (!response.status) {
      throw Exception(response.content['message']);
    }
  }

  Future<Goal> setMilestones(Goal goal, List<Milestone> milestones) async {
    ApiResponse response =
        await _goalsApiService.setMilestones(goal, milestones);
    if (response.status) {
      return Goal.fromJson(response.content);
    } else {
      throw Exception(response.content['message']);
    }
  }
}
