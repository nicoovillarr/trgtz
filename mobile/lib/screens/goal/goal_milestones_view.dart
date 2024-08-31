import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/providers/index.dart';

class GoalMilestonesView extends StatefulWidget {
  const GoalMilestonesView({super.key});

  @override
  State<GoalMilestonesView> createState() => _GoalMilestonesViewState();
}

class _GoalMilestonesViewState
    extends BaseEditorScreen<GoalMilestonesView, Goal> {
  @override
  Future afterFirstBuild(BuildContext context) async {
    setIsLoading(true);
    await context.read<SingleGoalProvider>().populate(store.state.user!,
        ModalRoute.of(context)!.settings.arguments as String);
    setIsLoading(false);

    subscribeToChannel('GOAL', viewModel.model!.goal.id, (message) {
      viewModel.processMessage(message);
      setState(() {});
    });
  }

  @override
  Widget body(BuildContext context) {
    if (viewModel.model != null) {
      return Selector<SingleGoalProvider, List<Milestone>>(
        selector: (context, provider) => provider.model?.goal.milestones ?? [],
        builder: (context, milestones, child) => ReorderableListView(
          buildDefaultDragHandles: viewModel.model?.goal.canEdit ?? false,
          onReorder: reorder,
          footer: canEdit && milestones.isNotEmpty
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
            for (final milestone in milestones)
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
        ),
      );
    } else {
      return const Center(child: Text('Goal not found'));
    }
  }

  @override
  List<Widget> get actions => canEdit
      ? [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              simpleBottomSheet(
                title: 'Add milestone',
                child: TextEditModal(
                  placeholder: 'Add milestone',
                  maxLength: 150,
                  maxLines: 3,
                  onSave: (title) => title != null && title.isNotEmpty
                      ? viewModel.createMilestone(title)
                      : null,
                ),
              );
            },
          ),
        ]
      : [];

  @override
  String? get title => 'Milestones';

  SingleGoalProvider get viewModel => context.read<SingleGoalProvider>();

  bool get canEdit => viewModel.model?.goal.canEdit ?? false;

  void reorder(int oldIndex, int newIndex, {bool force = false}) {
    if (oldIndex == newIndex) {
      return;
    }

    if (viewModel.model!.goal.milestones
            .any((element) => element.completedOn != null) &&
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

    setIsLoading(true);

    if (oldIndex < newIndex) {
      newIndex--;
    }

    final milestones = viewModel.model!.goal.milestones.toList();
    final milestone = milestones.removeAt(oldIndex);
    milestones.insert(newIndex, milestone);
    for (final m in milestones) {
      m.completedOn = null;
    }
    viewModel.setMilestones(milestones).then((_) => setIsLoading(false));
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

    setIsLoading(true);
    viewModel.deleteMilestone(milestone).then((value) {
      setIsLoading(false);
      setState(() {});
    });
  }
}
