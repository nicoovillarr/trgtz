import 'package:trgtz/models/index.dart';
import 'package:trgtz/store/index.dart';

abstract class ReducerActionBase {
  execute(ApplicationState currentState);
}

class AddDateYearAction implements ReducerActionBase {
  final int years;

  const AddDateYearAction({required this.years});

  @override
  execute(ApplicationState currentState) {
    final DateTime newDate = DateTime(currentState.date.year + years,
        currentState.date.month, currentState.date.day);
    return currentState.copyWith(date: newDate);
  }
}

class SetGoalsAction implements ReducerActionBase {
  final List<Goal> goals;

  const SetGoalsAction({required this.goals});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(goals: goals);
  }
}

class CreateGoalAction implements ReducerActionBase {
  final Goal goal;

  const CreateGoalAction({required this.goal});

  @override
  execute(ApplicationState currentState) {
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
  execute(ApplicationState currentState) {
    return currentState.copyWith(
      goals: currentState.goals.map((e) => e.id == goal.id ? goal : e).toList(),
    );
  }
}

class UpdateGoalFieldsAction implements ReducerActionBase {
  final Goal goal;
  final Map<String, dynamic> fields;

  const UpdateGoalFieldsAction({required this.goal, required this.fields});

  @override
  execute(ApplicationState currentState) {
    final Goal updatedGoal = Goal.fromJson({
      ...goal.toJson(),
      ...fields,
    });
    return currentState.copyWith(
      goals: currentState.goals
          .map((e) => e.id == goal.id ? updatedGoal : e)
          .toList(),
    );
  }
}

class DeleteGoalAction implements ReducerActionBase {
  final Goal goal;

  const DeleteGoalAction({required this.goal});

  @override
  execute(ApplicationState currentState) {
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
  execute(ApplicationState currentState) {
    return currentState.copyWith(user: user);
  }
}

class SetIsLoadingAction implements ReducerActionBase {
  final bool isLoading;

  const SetIsLoadingAction({required this.isLoading});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(isLoading: isLoading);
  }
}

class SetCurrentEditorObjectAction implements ReducerActionBase {
  final dynamic obj;

  const SetCurrentEditorObjectAction({required this.obj});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(currentEditorObject: obj);
  }
}

class SetAlertsAction implements ReducerActionBase {
  final List<Alert> alerts;

  const SetAlertsAction({required this.alerts});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(alerts: alerts);
  }
}

class SetFriendsAction implements ReducerActionBase {
  final List<Friendship> friends;

  const SetFriendsAction({required this.friends});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(friends: friends);
  }
}

class UpdateUserFields implements ReducerActionBase {
  final Map<String, dynamic> fields;

  const UpdateUserFields({required this.fields});

  @override
  execute(ApplicationState currentState) {
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
  execute(ApplicationState currentState) {
    final obj = currentState.currentEditorObject.toJson();
    for (final key in fields.keys) {
      if (key.contains('.')) {
        final keys = key.split('.');
        dynamic current = obj;
        for (int i = 0; i < keys.length - 1; i++) {
          if (int.tryParse(keys[i]) != null) {
            final index = int.parse(keys[i]);
            current = current[index];
          } else {
            current = current[keys[i]];
          }
        }
        final lastKey = keys.last;
        if (int.tryParse(lastKey) != null) {
          final index = int.parse(lastKey);
          current[index] = fields[key];
        } else {
          current[lastKey] = fields[key];
        }
      } else {
        obj[key] = fields[key];
      }
    }
    return currentState.copyWith(currentEditorObject: converter(obj));
  }
}

class SetPendingFriendRequestsAction implements ReducerActionBase {
  final int count;

  const SetPendingFriendRequestsAction({required this.count});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(pendingFriendRequests: count);
  }
}

class AddPendingFriendRequestAction implements ReducerActionBase {
  const AddPendingFriendRequestAction();

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(
      pendingFriendRequests: (currentState.pendingFriendRequests ?? 0) + 1,
    );
  }
}

class AddFriendAction implements ReducerActionBase {
  final Friendship newFriend;
  const AddFriendAction({required this.newFriend});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(
      friends: [
        ...currentState.friends!,
        newFriend,
      ],
    );
  }
}

class DeleteFriend implements ReducerActionBase {
  final String friendId;
  const DeleteFriend({required this.friendId});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(
      friends: currentState.friends!
          .where((element) => element.otherUserId != friendId)
          .toList(),
    );
  }
}

class AddAlertAction implements ReducerActionBase {
  final Alert alert;

  const AddAlertAction({required this.alert});

  @override
  execute(ApplicationState currentState) {
    return currentState.copyWith(
      alerts: [
        alert,
        ...?currentState.alerts,
      ],
    );
  }
}
