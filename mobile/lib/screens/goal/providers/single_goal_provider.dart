import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/services/index.dart';

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

  SingleGoalProviderModel? get model => _model;

  bool get isLoaded => _isLoaded;

  bool get hasReacted =>
      model?.goal.reactions
          .any((reaction) => reaction.user.id == model!.me.id) ??
      false;

  int get reactionCount => model?.goal.reactions.length ?? 0;

  Future<SingleGoalProvider> populate(User me, String goalId) async {
    Goal goal = await _moduleService.getGoal(goalId);
    _model = SingleGoalProviderModel(me, goal);
    _isLoaded = true;
    notifyListeners();

    return this;
  }

  Future updateGoal(Goal editedGoal) async {
    await _moduleService.updateGoal(editedGoal);
    _model = SingleGoalProviderModel(model!.me, editedGoal);
    notifyListeners();
  }

  Future deleteGoal() async {
    if (model == null) {
      return;
    }

    await _moduleService.deleteGoal(model!.goal);
    _model = null;
    notifyListeners();
  }

  Future completeGoal() async {
    if (model == null) {
      return;
    }

    Goal goal = model!.goal.deepCopy();
    goal.completedOn = DateTime.now();

    await _moduleService.completeGoal(goal);

    _model = SingleGoalProviderModel(model!.me, goal);
    notifyListeners();
  }

  Future createMilestone(String title) async {
    if (model == null) {
      return;
    }

    Milestone milestone =
        await _moduleService.createMilestone(model!.goal, title);
    Goal goal = model!.goal.deepCopy();
    goal.milestones.add(milestone);

    _model = SingleGoalProviderModel(model!.me, goal);
    notifyListeners();
  }

  Future updateMilestone(Goal goal, Milestone milestone) async {
    await _moduleService.updateMilestone(goal, milestone);
    goal.milestones = goal.milestones
        .map((m) => m.id == milestone.id ? milestone : m)
        .toList();
    _model = SingleGoalProviderModel(model!.me, goal);
    notifyListeners();
  }

  Future setMilestones(List<Milestone> milestones) async {
    Goal newGoal = await _moduleService.setMilestones(model!.goal, milestones);
    _model = SingleGoalProviderModel(model!.me, newGoal);
    notifyListeners();
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

  Future reactToGoal(Goal goal, String reactionKey) async {
    await _moduleService.reactToGoal(goal, reactionKey);
    Goal newGoal = await _moduleService.getGoal(goal.id);
    _model = SingleGoalProviderModel(model!.me, newGoal);
    notifyListeners();
  }

  Future removeReaction(Goal goal) async {
    _moduleService.removeReaction(goal);
    Goal newGoal = goal.deepCopy();
    newGoal.reactions = newGoal.reactions
        .where((reaction) => reaction.user != model!.me.id)
        .toList();
    _model = SingleGoalProviderModel(model!.me, newGoal);
    notifyListeners();
  }

  Future createComment(Goal goal, String text) async {
    await _moduleService.createComment(goal, text);
    Goal newGoal = await _moduleService.getGoal(goal.id);
    _model = SingleGoalProviderModel(model!.me, newGoal);
    notifyListeners();
  }
}
