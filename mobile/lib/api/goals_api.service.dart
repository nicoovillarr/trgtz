import 'package:trgtz/api/api.service.dart';
import 'package:trgtz/models/index.dart';

class GoalsApiService extends ApiBaseService {
  GoalsApiService() {
    controller = 'goals';
  }

  Future<ApiResponse> createGoals(List<Goal> goals) async =>
      await post('', goals.map((goal) => goal.toJson()).toList());

  Future<ApiResponse> getGoals() async => await get('');

  Future<ApiResponse> getGoalById(String id) async => await get(id);

  Future<ApiResponse> deleteGoal(String id) async => await delete(id, null);

  Future<ApiResponse> updateGoal(Goal goal) async =>
      await put(goal.id, goal.toJson());

  Future<ApiResponse> setMilestones(
          Goal goal, List<Milestone> milestones) async =>
      await put('${goal.id}/milestones',
          milestones.map((milestone) => milestone.toJson()).toList());

  Future<ApiResponse> updateMilestone(Goal goal, Milestone milestone) async =>
      await put('${goal.id}/milestones/${milestone.id}', milestone.toJson());

  Future<ApiResponse> createMilestone(Goal goal, String title) async =>
      await post('${goal.id}/milestones', {'title': title});

  Future<ApiResponse> reactToGoal(Goal goal, String reaction) async =>
      await post('${goal.id}/reactions', {'reaction': reaction});

  Future<ApiResponse> removeReaction(Goal goal) async =>
      await delete('${goal.id}/reactions', null);

  Future<ApiResponse> createComment(Goal goal, String text) async =>
      await post('${goal.id}/comments', {'text': text});
}
