import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/utils.dart';
import 'package:confetti/confetti.dart';

import 'dart:math';

class GoalViewScreen extends StatefulWidget {
  const GoalViewScreen({super.key});

  @override
  State<GoalViewScreen> createState() => _GoalViewScreenState();
}

class _GoalViewScreenState extends BaseEditorScreen<GoalViewScreen, Goal> {
  late ConfettiController _centerController;

  @override
  void customInitState() {
    _centerController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  Future afterFirstBuild(BuildContext context) async {
    String goalId = ModalRoute.of(context)!.settings.arguments as String;
    setIsLoading(true);
    ModuleService.getGoal(goalId).then((goal) {
      store.dispatch(SetCurrentEditorObjectAction(obj: goal));
      setIsLoading(false);
      setState(() {});
    });
  }

  @override
  Widget body(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StoreConnector<AppState, Goal?>(
      converter: (store) => store.state.currentEditorObject as Goal?,
      builder: (ctx, goal) {
        if (goal == null) {
          return const Center(
            child: Text('Goal not found'),
          );
        }
        return Stack(
          children: [
            _buildBody(size, goal),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _centerController,
                blastDirection: -pi / 2,
                maxBlastForce: 15,
                minBlastForce: 10,
                emissionFrequency: 0.03,
                numberOfParticles: 20,
                gravity: 0.05,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  List<Widget> get actions => [
        if (entity != null)
          CustomPopUpMenuButton(
            items: [
              MenuItem(
                title: 'Change title',
                onTap: () => simpleBottomSheet(
                  title: 'Change title',
                  child: TextEditModal(
                    placeholder: 'I wanna...',
                    initialValue: entity!.title,
                    maxLength: 50,
                    maxLines: 1,
                    validate: (title) => title != null && title.isNotEmpty
                        ? null
                        : 'Title cannot be empty',
                    onSave: (s) => _onSaveField(
                      goal: entity!,
                      field: 'title',
                      newValue: Utils.sanitize(s ?? ''),
                    ),
                  ),
                ),
              ),
              MenuItem(
                title: 'Milestones',
                onTap: () => Navigator.of(context)
                    .pushNamed('/goal/milestones', arguments: entity!.id),
              ),
              MenuItem(
                title: 'Delete',
                onTap: _onDeleteGoal,
              ),
            ],
          ),
      ];

  Widget _buildBody(Size size, Goal goal) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: SeparatedColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDesc(size, goal),
            if (goal.milestones.isEmpty) _buildNewMilestoneButton(goal),
            if (goal.milestones.isNotEmpty) _buildMilestonesSummary(goal),
          ],
        ),
      );

  Row _buildNewMilestoneButton(Goal goal) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: DottedBorder(
                  dashPattern: const [8],
                  padding: const EdgeInsets.all(0),
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  borderPadding: EdgeInsets.zero,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      // side: const BorderSide(color: mainColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(
                      '/goal/milestones',
                      arguments: goal.id,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'View milestone',
                          style: TextStyle(color: mainColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesc(Size size, Goal goal) => Material(
        color: const Color.fromARGB(0, 65, 37, 37),
        child: InkWell(
          onTap: () => _showDescriptionModal(size, goal),
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: goal.description != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.description!,
                        style: const TextStyle(
                          color: Color(0xFF003E4B),
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Color(0xFF003E4B),
                            size: 16.0,
                          ),
                        ],
                      )
                    ],
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add description',
                        style: TextStyle(
                          color: Color(0xFF003E4B),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Icon(
                        Icons.edit,
                        color: Color(0xFF003E4B),
                        size: 16.0,
                      ),
                    ],
                  ),
          ),
        ),
      );

  Widget _buildMilestonesSummary(Goal goal) {
    final int completed =
        goal.milestones.where((m) => m.completedOn != null).length;
    final int total = goal.milestones.length;
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SeparatedColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ProgressBar(
                    height: 6,
                    percentage: completed / total,
                    showPercentage: false,
                    cornerRadius: 4,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Text('$completed/$total'),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goal.getMilestonesSublist().length,
              itemBuilder: (context, index) {
                final milestone = goal.getMilestonesSublist()[index];
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: milestone.completedOn != null ? 0.5 : 1.0,
                  child: Stack(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        title: Text(
                          milestone.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                        leading: Checkbox(
                          value: milestone.completedOn != null,
                          activeColor: mainColor,
                          onChanged: (_) => _onMilestoneCompleted(milestone),
                        ),
                        onTap: () => _onMilestoneCompleted(milestone),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (goal.getMilestonesSublist().length < goal.milestones.length)
              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                onPressed: () => Navigator.of(context).pushNamed(
                  '/goal/milestones',
                  arguments: goal.id,
                ),
                child: const Text(
                  'View all milestones',
                  style: TextStyle(
                    color: mainColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onSaveField({
    required Goal goal,
    required String field,
    String? newValue = '',
  }) {
    Goal editedGoal = goal;
    setter(String? v) {
      switch (field) {
        case 'title':
          if (v == null) throw 'Title cannot be null';
          editedGoal.title = v;
          break;
        case 'description':
          editedGoal.description = v != null && v.isNotEmpty ? v : null;
          break;
        default:
          throw 'Invalid field';
      }
    }

    setter(newValue);

    setIsLoading(true);
    ModuleService.updateGoal(store, goal).then((_) {
      setIsLoading(false);
      showSnackBar('Goal updated successfully!');
    });
  }

  void _showDescriptionModal(Size size, Goal goal) => simpleBottomSheet(
        title: 'Add description',
        height: size.height * 0.9,
        child: TextEditModal(
          placeholder: 'Description',
          initialValue: goal.description,
          maxLength: 150,
          maxLines: 3,
          onSave: (s) => _onSaveField(
              goal: goal,
              field: 'description',
              newValue: Utils.sanitize(s ?? '')),
        ),
      );

  void _onDeleteGoal() {
    if (entity == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete goal'),
        content: Text('Are you sure you want to delete \'${entity!.title}\'?'),
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
              _deleteGoal();
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

  void _deleteGoal() {
    setIsLoading(true);
    ModuleService.deleteGoal(store, entity!).then(
      (_) {
        setIsLoading(false);
        Navigator.of(context)
            .popUntil((route) => route.settings.name == '/home');
        showSnackBar('Goal deleted successfully!');
      },
    );
  }

  void _onMilestoneCompleted(Milestone milestone) {
    final int currentIndex = entity!.milestones.indexOf(milestone);
    final bool hasIncompleteMilestones = entity!.milestones
        .sublist(0, currentIndex)
        .any((m) => m.completedOn == null);

    final bool hasCompletedMilestones = entity!.milestones
        .sublist(currentIndex + 1)
        .any((m) => m.completedOn != null);

    if (hasCompletedMilestones) {
      showSnackBar(
        'Cannot uncomplete a milestone before the last completed milestone.',
      );
      return;
    }

    if (hasIncompleteMilestones) {
      showSnackBar(
        'You must complete the previous milestones first.',
      );
      return;
    }

    milestone.completedOn =
        milestone.completedOn == null ? DateTime.now() : null;
    ModuleService.updateMilestone(store, entity!, milestone).then((_) {
      if (entity!.milestones.every((element) => element.completedOn != null) &&
          entity!.completedOn != null) {
        showSnackBar('Goal completed!');
        _centerController.play();
        Future.delayed(const Duration(milliseconds: 10), () {
          _centerController.stop();
        });
      }
    });
  }

  @override
  String? get title => entity?.title;

  @override
  Goal? get entity => store.state.currentEditorObject;

  @override
  FloatingActionButton? get fab => entity != null &&
          entity!.completedOn == null &&
          entity!.deletedOn == null &&
          (entity!.milestones.isEmpty ||
              entity!.milestones.every((m) => m.completedOn != null))
      ? FloatingActionButton.extended(
          onPressed: () async {
            ModuleService.completeGoal(store, entity!).then((_) {
              setState(() {});
              _centerController.play();
              Future.delayed(const Duration(milliseconds: 10), () {
                _centerController.stop();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Goal completed!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      ModuleService.updateGoal(
                              store, entity!..completedOn = null)
                          .then((value) => setState(() {}));
                    },
                  ),
                ),
              );
            });
          },
          label: const Text('Complete'),
        )
      : null;
}
