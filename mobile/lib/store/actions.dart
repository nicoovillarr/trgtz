import 'package:trgtz/models/index.dart';
import 'package:trgtz/store/index.dart';

abstract class ReducerActionBase {
  execute(AppState currentState);
}

class AddDateYearAction implements ReducerActionBase {
  final int years;

  const AddDateYearAction({required this.years});

  @override
  execute(AppState currentState) {
    final DateTime newDate = DateTime(currentState.date.year + years,
        currentState.date.month, currentState.date.day);
    return currentState.copyWith(date: newDate);
  }
}

class SetGoalsAction implements ReducerActionBase {
  final List<Goal> goals;

  const SetGoalsAction({required this.goals});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(goals: goals);
  }
}

class CreateGoalAction implements ReducerActionBase {
  final Goal goal;

  const CreateGoalAction({required this.goal});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(goals: [
      ...currentState.goals,
      goal,
    ]);
  }
}

class UpdateGoalAction implements ReducerActionBase {
  final Goal goal;

  const UpdateGoalAction({required this.goal});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(
      goals: currentState.goals.map((e) => e.id == goal.id ? goal : e).toList(),
    );
  }
}

class DeleteGoalAction implements ReducerActionBase {
  final Goal goal;

  const DeleteGoalAction({required this.goal});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(
      goals:
          currentState.goals.where((element) => element.id != goal.id).toList(),
    );
  }
}

class SetUserAction implements ReducerActionBase {
  final User user;

  const SetUserAction({required this.user});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(user: user);
  }
}

class SetIsLoadingAction implements ReducerActionBase {
  final bool isLoading;

  const SetIsLoadingAction({required this.isLoading});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(isLoading: isLoading);
  }
}

class SetCurrentEditorObjectAction implements ReducerActionBase {
  final dynamic obj;

  const SetCurrentEditorObjectAction({required this.obj});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(currentEditorObject: obj);
  }
}
