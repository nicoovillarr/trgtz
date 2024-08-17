import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/providers/index.dart';
import 'package:trgtz/screens/goal/widgets/index.dart';
import 'package:trgtz/utils.dart';
import 'package:confetti/confetti.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'dart:math';

class SingleGoalScreen extends StatefulWidget {
  const SingleGoalScreen({super.key});

  @override
  State<SingleGoalScreen> createState() => _SingleGoalScreenState();
}

class _SingleGoalScreenState extends BaseEditorScreen<SingleGoalScreen, Goal> {
  late final String goalId;
  late ConfettiController _centerController;

  String get reactionText {
    int othersReactionCount =
        viewModel.reactionCount - (viewModel.hasReacted ? 1 : 0);
    bool shouldIncludeAnd = viewModel.hasReacted && viewModel.reactionCount > 1;

    final youText = viewModel.hasReacted ? 'You' : '';
    final andText = shouldIncludeAnd ? ' and' : '';
    final othersText = othersReactionCount > 0 ? ' $othersReactionCount' : '';
    final usersText = youText.isEmpty && othersReactionCount > 0
        ? (othersReactionCount == 1 ? ' user' : ' users')
        : '';

    return '$youText$andText$othersText$usersText reacted to this goal'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void customInitState() {
    _centerController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  Future afterFirstBuild(BuildContext context) async {
    setIsLoading(true);
    final viewModel = await context.read<SingleGoalProvider>().populate(
          store.state.user!,
          ModalRoute.of(context)!.settings.arguments as String,
        );
    setIsLoading(false);

    if (!viewModel.model!.goal.canEdit) {
      return;
    }

    subscribeToChannel('GOAL', viewModel.model!.goal.id, (message) {
      switch (message.type) {
        case broadcastTypeGoalUpdate:
          viewModel.updateGoalField(message.data);
          break;

        case broadcastTypeGoalSetMilestones:
          Map<String, dynamic> changes = {
            'milestones': message.data,
          };
          viewModel.updateGoalField(changes);
          break;

        case broadcastTypeGoalDelete:
          Navigator.of(context)
              .popUntil((route) => route.settings.name == '/home');
          showSnackBar('Goal deleted by another user.');
          break;
      }

      setState(() {});
    });
  }

  @override
  Widget body(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Selector<SingleGoalProvider, Goal?>(
      selector: (context, viewModel) => viewModel.model?.goal,
      builder: (ctx, goal, child) {
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
        if (viewModel.model != null && viewModel.model!.goal.canEdit)
          CustomPopUpMenuButton(
            items: [
              MenuItem(
                title: 'Change title',
                onTap: () => simpleBottomSheet(
                  title: 'Change title',
                  child: TextEditModal(
                    placeholder: 'I wanna...',
                    initialValue: viewModel.model!.goal.title,
                    maxLength: 50,
                    maxLines: 1,
                    validate: (title) => title != null && title.isNotEmpty
                        ? null
                        : 'Title cannot be empty',
                    onSave: (s) => _onSaveField(
                      goal: viewModel.model!.goal,
                      field: 'title',
                      newValue: Utils.sanitize(s ?? ''),
                    ),
                  ),
                ),
              ),
              MenuItem(
                title: 'Milestones',
                onTap: () => Navigator.of(context).pushNamed('/goal/milestones',
                    arguments: viewModel.model!.goal.id),
              ),
              MenuItem(
                title: 'Delete',
                onTap: _onDeleteGoal,
              ),
            ],
          ),
      ];

  Widget _buildBody(Size size, Goal goal) => RefreshIndicator(
        onRefresh: () async {
          await viewModel.populate(store.state.user!, goal.id);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SeparatedColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.0,
              children: [
                _buildDesc(size, goal),
                if (goal.milestones.isEmpty && goal.canEdit)
                  _buildNewMilestoneButton(goal),
                if (goal.milestones.isNotEmpty) _buildMilestonesSummary(goal),
                if (goal.reactions.isNotEmpty) _buildReactions(goal),
                if (!goal.canEdit)
                  GoalInteractions(
                    goal: goal,
                    onReaction: _onReaction,
                    onShowComments: () {},
                    onRemoveReaction: _onRemoveReaction,
                  ),
                const Divider(),
                _buildEventHistory(goal),
              ],
            ),
          ),
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
          onTap: () => goal.canEdit ? _showDescriptionModal(size, goal) : null,
          borderRadius: BorderRadius.circular(4.0),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: goal.description != null && goal.description!.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.description!,
                        style: const TextStyle(
                          color: Color(0xFF003E4B),
                        ),
                      ),
                      if (goal.canEdit)
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
                : goal.canEdit
                    ? const Row(
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
                      )
                    : const Text('This goal has no description'),
          ),
        ),
      );

  Widget _buildMilestonesSummary(Goal goal) {
    final int completed =
        goal.milestones.where((m) => m.completedOn != null).length;
    final int total = goal.milestones.length;
    return TCard(
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
                        title: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: goal.canEdit ? 0.0 : 16.0),
                          child: Text(
                            milestone.title,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        leading: goal.canEdit
                            ? Checkbox(
                                value: milestone.completedOn != null,
                                activeColor: mainColor,
                                onChanged: (_) =>
                                    _onMilestoneCompleted(milestone),
                              )
                            : null,
                        onTap: () => goal.canEdit
                            ? _onMilestoneCompleted(milestone)
                            : null,
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
    Goal editedGoal = goal.deepCopy();
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
    viewModel.updateGoal(editedGoal).then((_) {
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
    if (viewModel.model?.goal == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete goal'),
        content: Text(
            'Are you sure you want to delete \'${viewModel.model?.goal.title}\'?'),
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
    viewModel.deleteGoal().then(
      (_) {
        setIsLoading(false);
        Navigator.of(context)
            .popUntil((route) => route.settings.name == '/home');
        showSnackBar('Goal deleted successfully!');
      },
    );
  }

  void _onMilestoneCompleted(Milestone milestone) {
    final int currentIndex =
        viewModel.model!.goal.milestones.indexOf(milestone);
    final bool hasIncompleteMilestones = viewModel.model!.goal.milestones
        .sublist(0, currentIndex)
        .any((m) => m.completedOn == null);

    final bool hasCompletedMilestones = viewModel.model!.goal.milestones
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

    Milestone copy = milestone.deepCopy();
    copy.completedOn = milestone.completedOn == null ? DateTime.now() : null;
    viewModel.updateMilestone(viewModel.model!.goal, copy).then((_) {
      if (viewModel.model!.goal.milestones
              .every((element) => element.completedOn != null) &&
          viewModel.model!.goal.completedOn != null) {
        showSnackBar('Goal completed!');
        _centerController.play();
        Future.delayed(const Duration(milliseconds: 10), () {
          _centerController.stop();
        });
      }
    });
  }

  @override
  String? get title => viewModel.model?.goal.title;

  @override
  FloatingActionButton? get fab => viewModel.model?.goal != null &&
          viewModel.model!.goal.completedOn == null &&
          viewModel.model!.goal.deletedOn == null &&
          viewModel.model!.goal.canEdit &&
          (viewModel.model!.goal.milestones.isEmpty ||
              viewModel.model!.goal.milestones
                  .every((m) => m.completedOn != null))
      ? FloatingActionButton.extended(
          onPressed: () async {
            viewModel.completeGoal().then((_) {
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
                      viewModel
                          .updateGoal(viewModel.model!.goal..completedOn = null)
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

  SingleGoalProvider get viewModel => context.read<SingleGoalProvider>();

  Widget _buildEventHistory(Goal goal) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => ListTile(
          leading: Icon(
            getEventIcon(goal.events[index]),
            size: 18.0,
          ),
          title: Text(
            goal.events[index].toString(),
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          trailing: Text(
            timeago.format(goal.events[index].createdOn),
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        ),
        itemCount: goal.events.length,
        shrinkWrap: true,
      );

  IconData getEventIcon(Event e) {
    switch (e.type) {
      case 'goal_created':
        return Icons.cloud;
      case 'goal_updated':
        return Icons.edit;
      case 'goal_completed':
        return Icons.flag;
      case 'milestone_created':
        return Icons.cloud;
      case 'milestone_completed':
        return Icons.check;
      default:
        return Icons.help;
    }
  }

  void _onReaction(String reactionType) {
    setIsLoading(true);
    viewModel.reactToGoal(viewModel.model!.goal, reactionType).then((_) {
      setIsLoading(false);
      showSnackBar('Reaction added!');
    }).catchError((_) {
      setIsLoading(false);
    });
  }

  Widget _buildReactions(Goal goal) => Row(
        children: [
          Dots(
            size: 20,
            dots: _getReactionsIcons(goal.reactions)
                .map((icon) => Icon(
                      icon,
                      size: 10,
                    ))
                .toList(),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              reactionText,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          )
        ],
      );

  List<IconData> _getReactionsIcons(List<Reaction> reactions) {
    Map<ReactionType, List<Reaction>> groupedReactions = {};
    groupedReactions = reactions.fold({}, (acc, cur) {
      if (acc.containsKey(cur.type)) {
        acc[cur.type]!.add(cur);
      } else {
        acc[cur.type] = [cur];
      }
      return acc;
    });

    List<ReactionType> sortedReactions = groupedReactions.keys.toList();
    final me = store.state.user!.id;
    sortedReactions.sort((a, b) {
      if (groupedReactions[a]!.any((reaction) => reaction.user == me)) {
        return -1;
      } else if (groupedReactions[b]!.any((reaction) => reaction.user == me)) {
        return 1;
      } else {
        return groupedReactions[b]!
            .length
            .compareTo(groupedReactions[a]!.length);
      }
    });

    return sortedReactions
        .map((type) => Reaction.getDisplayIcon(type))
        .toList();
  }

  _onRemoveReaction() {
    setIsLoading(true);
    viewModel.removeReaction(viewModel.model!.goal).then((_) {
      setIsLoading(false);
      showSnackBar('Reaction removed!');
    }).catchError((_) {
      setIsLoading(false);
    });
  }
}
