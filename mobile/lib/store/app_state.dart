import 'package:trgtz/models/index.dart';

class AppState {
  DateTime date;
  List<Goal> goals;

  AppState({
    required this.date,
    required this.goals,
  });

  AppState copyWith({
    DateTime? date,
    List<Goal>? goals,
  }) {
    return AppState(
      date: date ?? this.date,
      goals: goals ?? this.goals,
    );
  }
}
