import 'package:mobile/models/index.dart';
import 'package:mobile/store/index.dart';

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
