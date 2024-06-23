import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';

class ModuleService {
  static final GoalService _goalService = GoalService();

  static Future<Goal> createGoal(Goal goal) async =>
      (await _goalService.createGoal([goal])).first;
}
