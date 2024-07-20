import 'package:flutter/material.dart' as x;
import 'package:trgtz/models/index.dart';

@x.immutable
class AppState {
  final DateTime date;
  final List<Goal> goals;
  final dynamic currentEditorObject;
  final User? user;
  final List<Friendship>? friends;
  final int? pendingFriendRequests;
  final bool? isLoading;
  final List<Alert>? alerts;

  const AppState({
    required this.date,
    this.goals = const [],
    this.user,
    this.friends,
    this.pendingFriendRequests = 0,
    this.isLoading = false,
    this.currentEditorObject,
    this.alerts,
  });

  AppState copyWith({
    DateTime? date,
    List<Goal>? goals,
    dynamic currentEditorObject,
    User? user,
    List<Friendship>? friends,
    int? pendingFriendRequests,
    bool? isLoading,
    List<Alert>? alerts,
  }) {
    AppState state = AppState(
      date: date ?? this.date,
      goals: goals ?? this.goals,
      currentEditorObject: currentEditorObject ?? this.currentEditorObject,
      user: user ?? this.user,
      friends: friends ?? this.friends,
      pendingFriendRequests: pendingFriendRequests ??
          this.pendingFriendRequests ??
          _calculateDefaultPendingFriendRequests(user, friends),
      isLoading: isLoading ?? this.isLoading,
      alerts: alerts ?? this.alerts,
    );

    return state;
  }

  int _calculateDefaultPendingFriendRequests(
      User? user, List<Friendship>? friends) {
    return user != null && friends != null
        ? friends
            .where((element) =>
                element.requester != user.id &&
                element.status == 'pending' &&
                element.deletedOn == null)
            .length
        : 0;
  }
}
