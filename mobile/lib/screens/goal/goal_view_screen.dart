import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mobile/models/goal.dart';
import 'package:mobile/store/actions.dart';
import 'package:mobile/store/app_state.dart';
import 'package:mobile/store/local_storage.dart';
import 'package:redux/redux.dart';

class GoalViewScreen extends StatefulWidget {
  const GoalViewScreen({super.key});

  @override
  State<GoalViewScreen> createState() => _GoalViewScreenState();
}

class _GoalViewScreenState extends State<GoalViewScreen> {
  @override
  Widget build(BuildContext context) {
    String goalId = ModalRoute.of(context)!.settings.arguments as String;
    return StoreConnector<AppState, Goal>(
      converter: (store) =>
          store.state.goals.firstWhere((element) => element.goalID == goalId),
      builder: (ctx, goal) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Goal'),
          elevation: 1,
        ),
        floatingActionButton: goal.completedOn == null
            ? FloatingActionButton.extended(
                onPressed: () {
                  Store<AppState> store = StoreProvider.of<AppState>(context);
                  Goal editedGoal = goal;
                  if (goal.completedOn == null) {
                    editedGoal.completedOn = DateTime.now();
                  }
                  store.dispatch(UpdateGoalAction(goal: editedGoal));
                  LocalStorage.saveGoals(store.state.goals);
                },
                label: const Text('Complete'),
              )
            : null,
        body: _buildBody(goal),
      ),
    );
  }

  Widget _buildBody(Goal goal) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalTitle(goal),
            const Text(
              'Status:',
              style: TextStyle(
                color: Color(0xFF808080),
                fontSize: 12,
              ),
            ),
            Text(_getStatusText(goal)),
          ],
        ),
      );

  Text _buildGoalTitle(Goal goal) {
    return Text(
      goal.title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    );
  }

  String _getStatusText(Goal goal) {
    if (goal.completedOn != null) {
      return 'Completed on ${goal.completedOn!.toIso8601String()}';
    } else {
      return 'Created on ${goal.createdOn.toIso8601String()}';
    }
  }
}
