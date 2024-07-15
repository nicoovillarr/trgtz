import 'package:flutter/material.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/services/index.dart';
import 'package:trgtz/store/index.dart';

class GoalMilestonesView extends StatefulWidget {
  const GoalMilestonesView({super.key});

  @override
  State<GoalMilestonesView> createState() => _GoalMilestonesViewState();
}

class _GoalMilestonesViewState
    extends BaseEditorScreen<GoalMilestonesView, Goal> {
  @override
  Future afterFirstBuild(BuildContext context) async {
    String goalId = ModalRoute.of(context)!.settings.arguments as String;
    setIsLoading(false);
    ModuleService.getGoal(goalId).then((goal) {
      store.dispatch(SetCurrentEditorObjectAction(obj: goal));
      setIsLoading(false);
      setState(() {});
    });
  }

  @override
  void initSubscriptions() {
    addSubscription(
      'goal',
      store.onChange
          .map((event) => event.currentEditorObject as Goal?)
          .listen((obj) {
        setState(() => entity = obj);
      }),
    );
    super.initSubscriptions();
  }

  @override
  Widget body(BuildContext context) {
    return entity != null
        ? ReorderableListView(
            onReorder: reorder,
            footer: entity?.milestones.isNotEmpty ?? false
                ? const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'Drag & drop to reorder.',
                        children: [TextSpan(text: '\nSwipe right to delete.')],
                        style: TextStyle(color: Colors.grey),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : null,
            children: [
              for (final milestone in entity!.milestones)
                Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) => delete(milestone),
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]),
                    child: Material(
                      elevation: 2,
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(milestone.title),
                      ),
                    ),
                  ),
                ),
            ],
          )
        : const Center(child: Text('Goal not found'));
  }

  @override
  List<Widget> get actions => [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            simpleBottomSheet(
              title: 'Add milestone',
              child: TextEditModal(
                placeholder: 'Add milestone',
                maxLength: 150,
                maxLines: 3,
                onSave: (s) => s != null ? add(s) : null,
              ),
            );
          },
        ),
      ];

  @override
  String? get title => 'Milestones';

  void reorder(int oldIndex, int newIndex, {bool force = false}) {
    if (oldIndex == newIndex) {
      return;
    }

    if (entity!.milestones.any((element) => element.completedOn != null) &&
        !force) {
      showMessage(
        'Wait!',
        'Some milestones have already been completed and doing this will uncomplete them. Do you want to continue?',
        positiveText: 'Yes',
        onPositiveTap: () {
          Navigator.of(context).pop();
          reorder(oldIndex, newIndex, force: true);
        },
        negativeText: 'Cancel',
      );
      return;
    }

    if (oldIndex < newIndex) {
      newIndex--;
    }

    final milestones = entity!.milestones.toList();
    final milestone = milestones.removeAt(oldIndex);
    milestones.insert(newIndex, milestone);
    for (final m in milestones) {
      m.completedOn = null;
    }
    ModuleService.setMilestones(store, entity!, milestones);
  }

  void add(String title) {
    final milestones = entity!.milestones.toList();
    milestones.add(Milestone.of(title: title));
    ModuleService.setMilestones(store, entity!, milestones);
  }

  void delete(Milestone milestone, {bool force = false}) {
    if (milestone.completedOn != null && !force) {
      showMessage(
        'Wait!',
        'This milestone has already been completed. Are you sure you want to delete it?',
        positiveText: 'Yes',
        onPositiveTap: () {
          Navigator.of(context).pop();
          delete(milestone, force: true);
        },
        negativeText: 'Cancel',
      );
      return;
    }

    final milestones = entity!.milestones.toList();
    milestones.remove(milestone);
    setIsLoading(true);
    ModuleService.setMilestones(store, entity!, milestones).then((value) {
      setIsLoading(false);
      setState(() {});
    });
  }
}
