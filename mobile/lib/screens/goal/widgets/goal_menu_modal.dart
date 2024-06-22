import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/models/goal.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/store/local_storage.dart';
import 'package:redux/redux.dart';

class GoalMenuAction {
  late IconData icon;
  late String title;
  late Color foregroundColor = Colors.black;
  late void Function() onTap;
}

class GoalMenuModal extends StatelessWidget {
  final Goal goal;
  const GoalMenuModal({required this.goal, super.key});

  List<GoalMenuAction> getActions(BuildContext context) => [
        GoalMenuAction()
          ..icon = Icons.edit
          ..title = 'Edit'
          ..onTap = () {
            _pop(context);
            Navigator.of(context)
                .pushNamed('/goal/edit', arguments: goal.goalID);
          },
        GoalMenuAction()
          ..icon = Icons.delete
          ..title = 'Delete'
          ..foregroundColor = Colors.red
          ..onTap = () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete goal'),
                content:
                    Text('Are you sure you want to delete \'${goal.title}\'?'),
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
                      Navigator.of(context)
                          .popUntil((route) => route.settings.name == '/');
                      Store<AppState> store =
                          StoreProvider.of<AppState>(context);
                      goal.deletedOn = DateTime.now();
                      store.dispatch(UpdateGoalAction(goal: goal));
                      LocalStorage.saveGoals(store.state.goals);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Goal deleted!'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              goal.deletedOn = null;
                              store.dispatch(UpdateGoalAction(goal: goal));
                              LocalStorage.saveGoals(store.state.goals);
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            );
          },
      ];

  @override
  Widget build(BuildContext context) {
    final actions = getActions(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView.builder(
        itemCount: actions.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) => ListTile(
          leading: Icon(
            actions[i].icon,
            size: 16.0,
            color: actions[i].foregroundColor,
          ),
          title: Text(
            actions[i].title,
            style: TextStyle(
              color: actions[i].foregroundColor,
            ),
          ),
          onTap: actions[i].onTap,
          dense: true,
        ),
      ),
    );
  }

  void _pop(BuildContext context) =>
      Navigator.of(context).canPop() ? Navigator.of(context).pop() : null;
}
