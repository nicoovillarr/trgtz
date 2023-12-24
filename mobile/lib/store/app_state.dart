import 'package:mobile/models/index.dart';

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

AppState initialState() {
  return AppState(
    date: DateTime.now(),
    goals: const [
      Goal(title: "Find a job", year: 2023),
      Goal(title: "Start a new business", year: 2023),
      Goal(title: "Take an airplane", year: 2023),
      Goal(title: "Make new friends", year: 2023),
      Goal(title: "Ask for a better salary", year: 2023),
      Goal(title: "Get my portfolio bigger", year: 2023),
      Goal(title: "Create a new YouTube channel", year: 2023),
      Goal(title: "Develop a new application", year: 2023),
    ],
  );
}
