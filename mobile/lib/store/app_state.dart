import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';

@immutable
class AppState {
  final DateTime date;
  final List<Goal> goals;
  final User? user;

  const AppState({
    required this.date,
    this.goals = const [],
    this.user,
  });

  AppState copyWith({
    DateTime? date,
    List<Goal>? goals,
    User? user,
  }) {
    return AppState(
      date: date ?? this.date,
      goals: goals ?? this.goals,
      user: user ?? this.user,
    );
  }
}
