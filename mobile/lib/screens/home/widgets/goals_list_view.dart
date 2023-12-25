import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mobile/models/index.dart';
import 'package:mobile/store/actions.dart';
import 'package:mobile/store/app_state.dart';
import 'package:mobile/store/local_storage.dart';
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
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.goals.length,
      itemBuilder: (ctx, idx) => ListTile(
        onTap: () => Navigator.of(ctx)
            .pushNamed('/goal', arguments: widget.goals[idx].goalID),
        onLongPress: () => _showDeleteDialog(ctx, widget.goals[idx]),
        title: Text(
          widget.goals[idx].title,
          style: const TextStyle(
            fontSize: 14,
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
              Store<AppState> store = StoreProvider.of<AppState>(context);
              store.dispatch(DeleteGoalAction(goal: goal));
              LocalStorage.saveGoals(store.state.goals);
              Navigator.of(context).pop();
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
}
