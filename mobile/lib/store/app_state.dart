import 'package:trgtz/models/index.dart';

class AppState {
  DateTime date;
  List<Goal> goals;
  String? token;

  AppState({
    required this.date,
    required this.goals,
    required this.token,
  });

  AppState copyWith({
    DateTime? date,
    List<Goal>? goals,
    String? token,
  }) {
    return AppState(
      date: date ?? this.date,
      goals: goals ?? this.goals,
      token: token,
    );
  }
}
