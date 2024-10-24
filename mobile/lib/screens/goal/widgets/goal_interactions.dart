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
  final Function() onRemoveReaction;
  const GoalInteractions({
    super.key,
    required this.goal,
    required this.onReaction,
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
            text: _buildText([
              _myReaction?.displayText ?? "",
              "(${widget.goal.reactions.length})"
            ]),
            color: _myReaction?.foregroundColor,
            onTap: () =>
                _myReaction != null ? _removeReaction() : _onReaction('like'),
            onLongPress: () => _popUpReactions(context),
          ),
          _buildButton(
            icon: Icons.message,
            text: "(${widget.goal.comments.length})",
          ),
          _buildButton(
            icon: Icons.visibility,
            text: "(${widget.goal.viewsCount})",
          ),
        ],
      );

  String _buildText(List<String> input) =>
      input.where((x) => x.isNotEmpty).join(" ");

  Widget _buildButton({
    required IconData icon,
    Function()? onTap,
    Function()? onLongPress,
    String? text,
    Color? color,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(4.0),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              if (text != null) const SizedBox(width: 8),
              if (text != null)
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.0,
                  ),
                ),
            ],
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
                      reactionTypeKey: GoalReactionType.like,
                      onReaction: () => _onReaction('like'),
                    ),
                    ReactionButton(
                      reactionTypeKey: GoalReactionType.love,
                      onReaction: () => _onReaction('love'),
                    ),
                    ReactionButton(
                      reactionTypeKey: GoalReactionType.happy,
                      onReaction: () => _onReaction('happy'),
                    ),
                    ReactionButton(
                      reactionTypeKey: GoalReactionType.cheer,
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

  GoalReaction? get _myReaction {
    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
    final user = store.state.user!.id;
    return widget.goal.reactions
        .where((reaction) => reaction.user.id == user)
        .firstOrNull;
  }
}
