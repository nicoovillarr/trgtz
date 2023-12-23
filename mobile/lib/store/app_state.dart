class AppState {
  DateTime date;

  AppState({
    required this.date,
  });

  AppState copyWith({
    DateTime? date,
  }) {
    return AppState(
      date: date ?? this.date,
    );
  }
}

AppState initialState() {
  return AppState(
    date: DateTime.now(),
  );
}
