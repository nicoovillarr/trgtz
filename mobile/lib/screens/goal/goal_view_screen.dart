import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/goal.dart';
import 'package:trgtz/screens/goal/services/index.dart';
import 'package:trgtz/store/app_state.dart';
import 'package:trgtz/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:confetti/confetti.dart';

import 'dart:math';

class GoalViewScreen extends StatefulWidget {
  const GoalViewScreen({super.key});

  @override
  State<GoalViewScreen> createState() => _GoalViewScreenState();
}

class _GoalViewScreenState extends BaseEditorScreen<GoalViewScreen, Goal> {
  late ConfettiController _centerController;
  late Goal? goal;

  @override
  void customInitState() {
    _centerController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  Widget body(BuildContext context) {
    String goalId = ModalRoute.of(context)!.settings.arguments as String;
    Size size = MediaQuery.of(context).size;
    return StoreConnector<AppState, Goal?>(
      converter: (store) => store.state.goals
          .where((element) => element.id == goalId)
          .firstOrNull,
      builder: (ctx, goal) {
        if (goal == null) {
          return const Center(
            child: Text('Goal not found'),
          );
        }
        return Stack(
          children: [
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
            _buildBody(size, goal),
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
                title: 'Delete',
                onTap: _onDeleteGoal,
              ),
            ],
          ),
      ];

  @override
  FloatingActionButton? get fab => entity != null && entity!.completedOn == null
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

  Widget _buildBody(Size size, Goal goal) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDesc(size, goal),
            _buildCreatedOn(goal),
          ],
        ),
      );

  Widget _buildDesc(Size size, Goal goal) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Material(
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
        ),
      );

  Widget _buildCreatedOn(Goal goal) => Wrap(
        direction: Axis.vertical,
        children: [
          const Text(
            'Created:',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 12,
            ),
          ),
          Text(timeago.format(goal.createdOn)),
        ],
      );

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

    ModuleService.updateGoal(store, goal).then((_) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Goal updated successfully!'),
        duration: Duration(seconds: 2),
      ));
    });
  }

  void _showDescriptionModal(Size size, Goal goal) => simpleBottomSheet(
        title: 'Add description',
        height: (size.height * 0.9).toInt(),
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
              ModuleService.deleteGoal(store, entity!).then(
                (_) {
                  Navigator.of(context)
                      .popUntil((route) => route.settings.name == '/home');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal deleted successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
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
  }

  @override
  String? get title => entity?.title;

  @override
  Goal? get entity => store.state.goals
      .where(
          (element) => element.id == ModalRoute.of(context)!.settings.arguments)
      .firstOrNull;
}
