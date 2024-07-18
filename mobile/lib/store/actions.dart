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

class SetAlertsAction implements ReducerActionBase {
  final List<Alert> alerts;

  const SetAlertsAction({required this.alerts});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(alerts: alerts);
  }
}

class SetFriendsAction implements ReducerActionBase {
  final List<Friendship> friends;

  const SetFriendsAction({required this.friends});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(friends: friends);
  }
}

class UpdateUserFields implements ReducerActionBase {
  final Map<String, dynamic> fields;

  const UpdateUserFields({required this.fields});

  @override
  execute(AppState currentState) {
    final User user = currentState.user!;
    final Map<String, dynamic> updatedFields = {
      ...user.toJson(),
      ...fields,
    };

    final User updatedUser = User.fromJson(updatedFields);
    return currentState.copyWith(user: updatedUser);
  }
}

class UpdateCurrentEditorObjectFields implements ReducerActionBase {
  final Map<String, dynamic> fields;
  final dynamic Function(Map<String, dynamic>) converter;

  const UpdateCurrentEditorObjectFields({
    required this.fields,
    required this.converter,
  });

  @override
  execute(AppState currentState) {
    final Map<String, dynamic> updatedFields = {
      ...currentState.currentEditorObject.toJson(),
      ...fields,
    };
    return currentState.copyWith(currentEditorObject: converter(updatedFields));
  }
}
