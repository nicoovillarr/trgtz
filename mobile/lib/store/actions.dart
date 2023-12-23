import 'package:mobile/store/index.dart';

abstract class ReducerActionBase {
  execute(AppState currentState);
}

class TestAction implements ReducerActionBase {
  final DateTime newDate;

  const TestAction({required this.newDate});

  @override
  execute(AppState currentState) {
    return currentState.copyWith(date: newDate);
  }
}
