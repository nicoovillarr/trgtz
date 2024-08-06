import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/services/index.dart';

class SingleGoalProviderModel {
  final Goal _goal;

  const SingleGoalProviderModel(
    this._goal,
  );

  Goal get goal => _goal;
}

class SingleGoalProvider extends ChangeNotifier {
  final ModuleService _moduleService = ModuleService();

  SingleGoalProviderModel? _model;
  bool _isLoaded = false;

  SingleGoalProviderModel? get model => _model;

  bool get isLoaded => _isLoaded;

  Future<SingleGoalProvider> populate(String goalId) async {
    Goal goal = await _moduleService.getGoal(goalId);
    _model = SingleGoalProviderModel(goal);
    _isLoaded = true;
    notifyListeners();

    return this;
  }

  Future updateGoal(Goal editedGoal) async {
    await _moduleService.updateGoal(editedGoal);
    _model = SingleGoalProviderModel(editedGoal);
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

    _model = SingleGoalProviderModel(goal);
    notifyListeners();
  }

  Future updateMilestone(Goal goal, Milestone milestone) async {
    await _moduleService.updateMilestone(goal, milestone);
    goal.milestones = goal.milestones
        .map((m) => m.id == milestone.id ? milestone : m)
        .toList();
    _model = SingleGoalProviderModel(goal);
    notifyListeners();
  }

  Future setMilestones(List<Milestone> milestones) async {
    Goal newGoal = await _moduleService.setMilestones(model!.goal, milestones);
    _model = SingleGoalProviderModel(newGoal);
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
    _model = SingleGoalProviderModel(Goal.fromJson(obj));
    notifyListeners();
  }
}
