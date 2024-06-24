import 'package:redux/redux.dart';
import 'package:trgtz/models/goal.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';

class ModuleService {
  static final GoalService _goalService = GoalService();

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
}
