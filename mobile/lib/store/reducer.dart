import 'package:trgtz/store/index.dart';

ApplicationState reduce(ApplicationState currentState, dynamic action) {
  if (action is ReducerActionBase) {
    return action.execute(currentState);
  }
  return currentState;
}
