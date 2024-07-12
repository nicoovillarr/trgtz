import 'package:redux/redux.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';

class ModuleService {
  static final GoalService _goalService = GoalService();

  static Future<Goal> getGoal(String id) => _goalService.getGoalById(id);

  static Future completeGoal(Store<AppState> store, Goal goal) {
    goal.completedOn = DateTime.now();
    return updateGoal(store, goal)
        .then((value) => store.dispatch(UpdateGoalAction(goal: goal)));
  }

  static Future updateGoal(Store<AppState> store, Goal goal) {
    return _goalService
        .updateGoal(goal)
        .then((value) => store.dispatch(UpdateGoalAction(goal: goal)));
  }

  static Future deleteGoal(Store<AppState> store, Goal goal) {
    return _goalService
        .deleteGoal(goal.id)
        .then((_) => store.dispatch(DeleteGoalAction(goal: goal)));
  }

  static Future setMilestones(
      Store<AppState> store, Goal goal, List<Milestone> milestones) {
    return _goalService.setMilestones(goal, milestones).then(
        (value) => store.dispatch(SetCurrentEditorObjectAction(obj: value)));
  }

  static Future updateMilestone(
      Store<AppState> store, Goal goal, Milestone milestone) {
    return _goalService.updateMilestone(goal, milestone).then(
        (value) => store.dispatch(SetCurrentEditorObjectAction(obj: value)));
  }
}
