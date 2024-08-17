import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/goal/widgets/index.dart';
import 'package:trgtz/store/index.dart';

class GoalInteractions extends StatefulWidget {
  final Goal goal;
  final Function(String type) onReaction;
  final Function() onShowComments;
  final Function() onRemoveReaction;
  const GoalInteractions({
    super.key,
    required this.goal,
    required this.onReaction,
    required this.onShowComments,
    required this.onRemoveReaction,
  });

  @override
  State<GoalInteractions> createState() => _GoalInteractionsState();
}

class _GoalInteractionsState extends State<GoalInteractions> {
  final double _reactionRowHeight = 56;
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _buildButton(
            icon:
                _myReaction != null ? _myReaction!.displayIcon : Icons.thumb_up,
            text: _myReaction != null ? _myReaction!.displayText : 'Like',
            color: _myReaction?.foregroundColor,
            onTap: () =>
                _myReaction != null ? _removeReaction() : _onReaction('like'),
            onLongPress: () => _popUpReactions(context),
          ),
          _buildButton(
            icon: Icons.message,
            text: 'Comment',
            onTap: () {},
          ),
        ],
      );

  Widget _buildButton({
    required IconData icon,
    required String text,
    required Function() onTap,
    Function()? onLongPress,
    Color? color,
  }) =>
      Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _hideReactions();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry(Offset position, Size size) => OverlayEntry(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideReactions,
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top:
                  position.dy - _reactionRowHeight - 16, // 8px above the button
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                height: _reactionRowHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ReactionButton(
                      reactionTypeKey: ReactionType.like,
                      onReaction: () => _onReaction('like'),
                    ),
                    ReactionButton(
                      reactionTypeKey: ReactionType.love,
                      onReaction: () => _onReaction('love'),
                    ),
                    ReactionButton(
                      reactionTypeKey: ReactionType.happy,
                      onReaction: () => _onReaction('happy'),
                    ),
                    ReactionButton(
                      reactionTypeKey: ReactionType.cheer,
                      onReaction: () => _onReaction('cheer'),
                    ),
                  ],
                ),
              ),
            ).animate(
              effects: [
                const FadeEffect(
                  duration: Duration(
                    milliseconds: 100,
                  ),
                ),
                const MoveEffect(
                  duration: Duration(
                    milliseconds: 100,
                  ),
                  curve: Curves.easeOut,
                  begin: Offset(0.0, 8.0),
                  end: Offset(0.0, 0.0),
                ),
              ],
            ),
          ],
        ),
      );

  void _removeReaction() {
    widget.onRemoveReaction();
  }

  void _onReaction(String reactionKey) {
    _hideReactions();
    widget.onReaction(reactionKey);
  }

  void _popUpReactions(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    _overlayEntry = _createOverlayEntry(buttonPosition, buttonSize);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideReactions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Reaction? get _myReaction {
    Store<AppState> store = StoreProvider.of<AppState>(context);
    final user = store.state.user!.id;
    return widget.goal.reactions
        .where((reaction) => reaction.user == user)
        .firstOrNull;
  }
}
