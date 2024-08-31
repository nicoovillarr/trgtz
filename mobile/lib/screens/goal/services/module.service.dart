import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';

class ModuleService {
  static final GoalService _goalService = GoalService();

  Future<Goal> getGoal(String id) => _goalService.getGoalById(id);

  Future completeGoal(Goal goal) {
    Goal copy = goal.deepCopy();
    copy.completedOn = DateTime.now();
    return updateGoal(copy);
  }

  Future updateGoal(Goal goal) {
    return _goalService.updateGoal(goal);
  }

  Future deleteGoal(Goal goal) => _goalService.deleteGoal(goal.id);

  Future createMilestone(Goal goal, String title) =>
      _goalService.createMilestone(goal, title);

  Future setMilestones(Goal goal, List<Milestone> milestones) =>
      _goalService.setMilestones(goal, milestones);

  Future updateMilestone(Goal goal, Milestone milestone) =>
      _goalService.updateMilestone(goal, milestone);

  Future reactToGoal(Goal goal, String reaction) =>
      _goalService.reactToGoal(goal, reaction);

  Future removeReaction(Goal goal) => _goalService.removeReaction(goal);

  Future createComment(Goal goal, String text) =>
      _goalService.createComment(goal, text);

  Future deleteMilestone(Goal goal, String id) =>
      _goalService.deleteMilestone(goal, id);
}
