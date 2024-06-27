import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/home/services/index.dart';
import 'package:trgtz/store/actions.dart';
import 'package:trgtz/store/app_state.dart';
import 'package:trgtz/utils.dart';
import 'package:redux/redux.dart';

class GoalsListView extends StatefulWidget {
  final List<Goal> goals;
  const GoalsListView({
    super.key,
    required this.goals,
  });

  @override
  State<GoalsListView> createState() => _GoalsListViewState();
}

class _GoalsListViewState extends State<GoalsListView> {
  List<Goal> goals = [];

  late final Store<AppState> store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    goals = Utils.sortGoals(widget.goals);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: goals.length,
      itemBuilder: (ctx, idx) => ListTile(
        onTap: () =>
            Navigator.of(ctx).pushNamed('/goal', arguments: goals[idx].id),
        onLongPress: () => _showDeleteDialog(ctx, goals[idx]),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goals[idx].title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (goals[idx].description != null)
                Text(
                  goals[idx].description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff606060),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete goal'),
        content: Text('Are you sure you want to delete \'${goal.title}\'?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xff606060)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              _deleteGoal(goal);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(Goal goal) {
    store.dispatch(const SetIsLoadingAction(isLoading: true));
    ModuleService.deleteGoal(goal.id).then((_) {
      store.dispatch(const SetIsLoadingAction(isLoading: false));
      store.dispatch(DeleteGoalAction(goal: goal));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal deleted successfully'),
        ),
      );
      // Navigator.of(context).pop();
    });
  }
}
