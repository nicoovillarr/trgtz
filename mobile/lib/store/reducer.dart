import 'package:mobile/store/index.dart';

AppState reduce(AppState currentState, dynamic action) {
  if (action is ReducerActionBase) {
    return action.execute(currentState);
  }
  return currentState;
}
