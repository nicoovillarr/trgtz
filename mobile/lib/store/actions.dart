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
      goals: currentState.goals
          .map((e) => e.goalID == goal.goalID ? goal : e)
          .toList(),
    );
  }
}

class DeleteGoalAction implements ReducerActionBase {
  final Goal goal;

  const DeleteGoalAction({required this.goal});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(
      goals: currentState.goals
          .where((element) => element.goalID != goal.goalID)
          .toList(),
    );
  }
}

class SetTokenAction implements ReducerActionBase {
  final String token;

  const SetTokenAction({required this.token});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(token: token);
  }
}

class RemoveTokenAction implements ReducerActionBase {
  const RemoveTokenAction();

  @override
  execute(AppState currentState) {
    return currentState.copyWith(token: null);
  }
}
