import 'package:flutter/material.dart';
import 'package:trgtz/app.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/services/index.dart';
import 'package:trgtz/services/websocket.service.dart';

import '../goal_constants.dart';

enum FooterType { comments, events, all }

class SingleGoalProviderModel {
  final User _me;
  final Goal _goal;

  const SingleGoalProviderModel(
    this._me,
    this._goal,
  );

  User get me => _me;

  Goal get goal => _goal;
}

class SingleGoalProvider extends ChangeNotifier {
  final ModuleService _moduleService = ModuleService();

  SingleGoalProviderModel? _model;
  bool _isLoaded = false;
  FooterType _footerType = FooterType.all;

  SingleGoalProviderModel? get model => _model;

  bool get isLoaded => _isLoaded;

  bool get hasReacted =>
      model?.goal.reactions
          .any((reaction) => reaction.user.id == model!.me.id) ??
      false;

  int get reactionCount => model?.goal.reactions.length ?? 0;

  String get reactionText {
    int othersReactionCount = reactionCount - (hasReacted ? 1 : 0);
    bool shouldIncludeAnd = hasReacted && reactionCount > 1;

    final youText = hasReacted ? 'You' : '';
    final andText = shouldIncludeAnd ? ' and' : '';
    final othersText = othersReactionCount > 0 ? ' $othersReactionCount' : '';
    final usersText = youText.isEmpty && othersReactionCount > 0
        ? (othersReactionCount == 1 ? ' user' : ' users')
        : '';

    return '$youText$andText$othersText$usersText reacted to this goal'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  FooterType get footerType => _footerType;

  set footerType(FooterType value) {
    _footerType = value;
    notifyListeners();
  }

  bool get canComplete =>
      model != null &&
      model!.goal.completedOn == null &&
      (model!.goal.milestones.isEmpty ||
          model!.goal.milestones.any((x) => x.completedOn == null) == false);

  Future<SingleGoalProvider> populate(User me, String goalId) async {
    Goal goal = await _moduleService.getGoal(goalId);
    _model = SingleGoalProviderModel(me, goal);
    _isLoaded = true;
    notifyListeners();

    return this;
  }

  void updateGoalField(Map<String, dynamic> fields) {
    if (model == null) {
      return;
    }

    final obj = model!.goal.toJson();
    for (final key in fields.keys) {
      if (key.contains('.')) {
        final keys = key.split('.');
        dynamic current = obj;
        for (int i = 0; i < keys.length - 1; i++) {
          if (int.tryParse(keys[i]) != null) {
            final index = int.parse(keys[i]);
            current = current[index];
          } else {
            current = current[keys[i]];
          }
        }
        final lastKey = keys.last;
        if (int.tryParse(lastKey) != null) {
          final index = int.parse(lastKey);
          current[index] = fields[key];
        } else {
          current[lastKey] = fields[key];
        }
      } else {
        obj[key] = fields[key];
      }
    }

    _model = SingleGoalProviderModel(model!.me, Goal.fromJson(obj));
    notifyListeners();
  }

  Future updateGoal(Goal editedGoal) async {
    if (model == null) {
      return;
    }

    await _moduleService.updateGoal(editedGoal);
  }

  Future deleteGoal() async {
    if (model == null) {
      return;
    }

    await _moduleService.deleteGoal(model!.goal);
  }

  Future completeGoal() async {
    if (model == null) {
      return;
    }

    final goal = model!.goal.deepCopy();
    goal.completedOn = DateTime.now();
    await _moduleService.completeGoal(goal);
  }

  Future createMilestone(String title) async {
    if (model == null) {
      return;
    }

    await _moduleService.createMilestone(model!.goal, title);
  }

  Future updateMilestone(Milestone milestone) async {
    if (model == null) {
      return;
    }

    await _moduleService.updateMilestone(model!.goal, milestone);
  }

  Future setMilestones(List<Milestone> milestones) async {
    if (model == null) {
      return;
    }

    await _moduleService.setMilestones(model!.goal, milestones);
  }

  Future deleteMilestone(Milestone milestone) async {
    if (model == null) {
      return;
    }

    await _moduleService.deleteMilestone(
      model!.goal,
      milestone.id,
    );
  }

  Future reactToGoal(String reactionKey) async {
    if (model == null) {
      return;
    }

    await _moduleService.reactToGoal(model!.goal, reactionKey);
  }

  Future removeReaction() async {
    if (model == null) {
      return;
    }

    await _moduleService.removeReaction(model!.goal);
  }

  Future createComment(String text) async {
    if (model == null) {
      return;
    }

    await _moduleService.createComment(model!.goal, text);
  }

  processMessage(WebSocketMessage message) {
    switch (message.type) {
      case broadcastTypeGoalUpdate:
        updateGoalField(message.data);
        break;

      case broadcastTypeGoalDelete:
        Navigator.of(navigatorKey.currentContext!)
            .popUntil((route) => route.settings.name == '/home');
        break;

      case broadcastTypeGoalCreateMilestone:
        updateGoalField({
          'milestones': [
            ...model!.goal.milestones,
            Milestone.fromJson(message.data)
          ].map((m) => m.toJson()).toList(),
        });
        break;

      case broadcastTypeGoalDeleteMilestone:
        updateGoalField({
          'milestones': model!.goal.milestones
              .where((m) => m.id != message.data)
              .map((m) => m.toJson())
              .toList(),
        });
        break;

      case broadcastTypeGoalUpdateMilestone:
        updateGoalField({
          'milestones': model!.goal.milestones
              .map((m) =>
                  message.data["_id"] == m.id ? message.data : m.toJson())
              .toList(),
        });
        break;

      case broadcastTypeGoalSetMilestones:
        Map<String, dynamic> changes = {
          'milestones': message.data,
        };
        updateGoalField(changes);
        break;

      case broadcastTypeGoalReacted:
        updateGoalField({
          'reactions': [
            ...model!.goal.reactions,
            Reaction.fromJson(message.data)
          ].map((r) => r.toJson()).toList(),
        });
        break;

      case broadcastTypeGoalReactDeleted:
        updateGoalField({
          'reactions': model!.goal.reactions
              .where((reaction) => reaction.user.id != message.data)
              .map((r) => r.toJson())
              .toList(),
        });
        break;

      case broadcastTypeGoalCommentCreated:
        updateGoalField({
          'comments': [...model!.goal.comments, Comment.fromJson(message.data)]
              .map((c) => c.toJson())
              .toList(),
        });
        break;

      case broadcastTypeGoalEventAdded:
        updateGoalField({
          'events': [...model!.goal.events, Event.fromJson(message.data)]
              .map((e) => e.toJson())
              .toList(),
        });
        break;
    }
  }
}
