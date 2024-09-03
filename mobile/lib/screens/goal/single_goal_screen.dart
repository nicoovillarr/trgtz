import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/providers/index.dart';
import 'package:trgtz/screens/goal/widgets/comment_card.dart';
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

  @override
  void customInitState() {
    _centerController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  Future loader() async {
    await context.read<SingleGoalProvider>().populate(
          store.state.user!,
          ModalRoute.of(context)!.settings.arguments as String,
        );
  }

  @override
  void didPushNext() {
    unsuscribeToChannel('GOAL', viewModel.model!.goal.id);
  }

  @override
  void didPopNext() {
    loader().then((_) {
      suscribeToGoalChannel();
    });
  }

  @override
  Future afterFirstBuild(BuildContext context) async {
    suscribeToGoalChannel();
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
            Padding(
              padding: const EdgeInsets.only(bottom: 56.0),
              child: _buildBody(size, goal),
            ),
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(
                    left: 24.0, right: 24.0, bottom: 40.0),
                child: MButton(
                  onPressed: _showComments,
                  borderRadius: 16.0,
                  text: 'Comment',
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  List<Widget> get actions => [
        CustomPopUpMenuButton(
          items: [
            MenuItem(
              title: 'Complete',
              enabled: viewModel.canComplete,
              onTap: () {
                showMessage(
                  'Complete goal',
                  'Are you sure you want to complete this goal?',
                  negativeText: 'Cancel',
                  onPositiveTap: () async {
                    Navigator.of(context).pop();
                    setIsLoading(true);
                    await viewModel.completeGoal();
                    setIsLoading(false);
                  },
                );
              },
            ),
            MenuItem(
              title: 'Change title',
              onTap: () => simpleBottomSheet(
                title: 'Change title',
                height: 0,
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
                    arguments: viewModel.model!.goal.id)
                // .then((_) => loader()),
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
              spacing: 8.0,
              children: [
                _buildDesc(size, goal),
                if (goal.milestones.isEmpty && goal.canEdit)
                  _buildNewMilestoneButton(goal),
                if (goal.milestones.isNotEmpty) _buildMilestonesSummary(goal),
                GoalInteractions(
                  goal: goal,
                  onReaction: _onReaction,
                  onRemoveReaction: _onRemoveReaction,
                ),
                const Divider(),
                _buildFooter(goal),
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
                          'View milestones',
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
              padding: EdgeInsets.zero,
              itemCount: goal.getMilestonesSublist().length,
              itemBuilder: (context, index) {
                final milestone = goal.getMilestonesSublist()[index];
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: milestone.completedOn != null ? 0.5 : 1.0,
                  child: ListTile(
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
                            onChanged: (_) => _onMilestoneCompleted(milestone),
                          )
                        : null,
                    onTap: () =>
                        goal.canEdit ? _onMilestoneCompleted(milestone) : null,
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
  }) async {
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
    try {
      await viewModel.updateGoal(editedGoal);
    } catch (e) {
      showSnackBar('Goal updated successfully!');
    } finally {
      setIsLoading(false);
    }
  }

  void _showDescriptionModal(Size size, Goal goal) => simpleBottomSheet(
        title: 'Add description',
        height: 0,
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
            onPressed: () async {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              await _deleteGoal();
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

  Future _deleteGoal() async {
    setIsLoading(true);
    try {
      await viewModel.deleteGoal();
    } catch (e) {
      showSnackBar('Goal deleted successfully!');
    } finally {
      setIsLoading(false);
    }
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

    setIsLoading(true);
    viewModel
        .updateMilestone(copy)
        .then((_) => setIsLoading(false))
        .catchError((_) => setIsLoading(false));
  }

  @override
  String? get title => viewModel.model?.goal.title;

  SingleGoalProvider get viewModel => context.read<SingleGoalProvider>();

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

  Future _onReaction(String reactionType) async {
    setIsLoading(true);
    try {
      await viewModel.reactToGoal(reactionType);
      showSnackBar('Reaction added!');
    } catch (e) {
      showSnackBar('An error occurred');
    } finally {
      setIsLoading(false);
    }
  }

  Future _onRemoveReaction() async {
    setIsLoading(true);
    try {
      viewModel.removeReaction();
      showSnackBar('Reaction removed!');
    } catch (e) {
      showSnackBar('An error occurred');
    } finally {
      setIsLoading(false);
    }
  }

  void _showComments() {
    GlobalKey<FormState> key = GlobalKey();
    String text = '';
    simpleBottomSheet(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              TextEdit(
                placeholder: 'Write a comment',
                maxLines: 2,
                maxLength: 200,
                validate: (s) => s != null && s.isNotEmpty
                    ? null
                    : 'Your comment cannot be empty',
                onSaved: (value) {
                  text = value ?? '';
                },
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        setIsLoading(true);
                        key.currentState!.save();
                        viewModel.createComment(text).then((_) {
                          showSnackBar('Comment added!');
                          key.currentState!.reset();
                          Navigator.of(context).pop();
                          setIsLoading(false);
                        }).catchError((_) {
                          showSnackBar('An error occurred');
                          setIsLoading(false);
                        });
                      }
                    },
                    text: 'Send',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Goal goal) {
    List<ModelBase> input;
    switch (viewModel.footerType) {
      case FooterType.comments:
        input = goal.comments;
        break;
      case FooterType.events:
        input = goal.events;
        break;
      case FooterType.all:
        List<Map<DateTime, ModelBase>> aux = goal.comments
            .map((e) => {e.createdOn: e as ModelBase})
            .followedBy(goal.events.map((e) => {e.createdOn: e as ModelBase}))
            .toList();
        aux.sort((a, b) => b.keys.first.compareTo(a.keys.first));
        input = aux.map((e) => e.values.first).toList();
        break;
      default:
        input = [];
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: input.length,
      itemBuilder: (context, index) => _buildFooterItem(input[index]),
      separatorBuilder: (context, index) => Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            height:
                input[index] is Event && input[index + 1] is Event ? 8.0 : 20.0,
            width: 1.0,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(ModelBase item) {
    if (item is Comment) {
      return CommentCard(
        comment: item,
        mine: item.user.id == store.state.user!.id,
      );
    } else if (item is Event) {
      return ListTile(
        contentPadding: const EdgeInsets.only(left: 5.0),
        leading: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey,
            ),
          ),
          child: Icon(
            getEventIcon(item),
            size: 12.0,
          ),
        ),
        title: Text(
          item.toString(),
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        trailing: Text(
          timeago.format(item.createdOn),
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      );
    } else {
      return const Placeholder();
    }
  }

  void suscribeToGoalChannel() {
    subscribeToChannel('GOAL', viewModel.model!.goal.id, (message) {
      viewModel.processMessage(message);
      setState(() {});
    });
  }
}
