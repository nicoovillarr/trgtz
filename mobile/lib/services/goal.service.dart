import 'package:trgtz/api/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/core/exceptions/index.dart';

class GoalService {
  final GoalsApiService _goalsApiService = GoalsApiService();

  Future<List<Goal>> getGoals() async {
    ApiResponse response = await _goalsApiService.getGoals();
    if (response.status) {
      return response.content.map<Goal>((goal) => Goal.fromJson(goal)).toList();
    } else {
      throw AppException(response.content);
    }
  }

  Future<Goal> getGoalById(String id) async {
    ApiResponse response = await _goalsApiService.getGoalById(id);
    if (response.status) {
      return Goal.fromJson(response.content);
    } else {
      throw AppException(response.content);
    }
  }

  Future<List<Goal>> createGoal(List<Goal> goals) async {
    ApiResponse response = await _goalsApiService.createGoals(goals);
    if (response.status) {
      return (response.content as List).map((e) => Goal.fromJson(e)).toList();
    } else {
      throw AppException(response.content);
    }
  }

  Future deleteGoal(String id) async {
    ApiResponse response = await _goalsApiService.deleteGoal(id);
    if (!response.status) {
      throw AppException(response.content);
    }
  }

  Future updateGoal(Goal goal) async {
    ApiResponse response = await _goalsApiService.updateGoal(goal);
    if (!response.status) {
      throw AppException(response.content);
    }
  }

  Future<Goal> setMilestones(Goal goal, List<Milestone> milestones) async {
    ApiResponse response =
        await _goalsApiService.setMilestones(goal, milestones);
    if (response.status) {
      return Goal.fromJson(response.content);
    } else {
      throw AppException(response.content);
    }
  }

  Future<Goal> updateMilestone(Goal goal, Milestone milestone) async {
    ApiResponse response =
        await _goalsApiService.updateMilestone(goal, milestone);
    if (response.status) {
      return Goal.fromJson(response.content);
    } else {
      throw AppException(response.content);
    }
  }

  Future<Milestone> createMilestone(Goal goal, String title) async {
    ApiResponse response = await _goalsApiService.createMilestone(goal, title);
    if (response.status) {
      return Milestone.fromJson(response.content);
    } else {
      throw AppException(response.content);
    }
  }

  Future reactToGoal(Goal goal, String reaction) async {
    ApiResponse response = await _goalsApiService.reactToGoal(goal, reaction);
    if (!response.status) {
      throw AppException(response.content);
    }
  }

  Future removeReaction(Goal goal) async {
    ApiResponse response = await _goalsApiService.removeReaction(goal);
    if (!response.status) {
      throw AppException(response.content);
    }
  }
}
