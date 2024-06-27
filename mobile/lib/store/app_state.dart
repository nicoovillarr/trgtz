import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';

@immutable
class AppState {
  final DateTime date;
  final List<Goal> goals;
  final User? user;
  final bool? isLoading;

  const AppState({
    required this.date,
    this.goals = const [],
    this.user,
    this.isLoading = false,
  });

  AppState copyWith({
    DateTime? date,
    List<Goal>? goals,
    User? user,
    bool? isLoading,
  }) {
    return AppState(
      date: date ?? this.date,
      goals: goals ?? this.goals,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
