import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';

@immutable
class AppState {
  final DateTime date;
  final List<Goal> goals;
  final dynamic currentEditorObject;
  final User? user;
  final List<Friendship>? friends;
  final bool? isLoading;

  const AppState({
    required this.date,
    this.goals = const [],
    this.user,
    this.friends,
    this.isLoading = false,
    this.currentEditorObject,
  });

  AppState copyWith({
    DateTime? date,
    List<Goal>? goals,
    dynamic currentEditorObject,
    User? user,
    List<Friendship>? friends,
    bool? isLoading,
  }) {
    return AppState(
      date: date ?? this.date,
      goals: goals ?? this.goals,
      currentEditorObject: currentEditorObject ?? this.currentEditorObject,
      user: user ?? this.user,
      friends: friends ?? this.friends,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
