import 'package:flutter/material.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends StatelessWidget {
  final Comment comment;
  final User me;
  final Function() onLongPress;
  final Function() onLike;
  final Function() onDislike;
  final Function() onReport;
  const CommentCard({
    super.key,
    required this.comment,
    required this.me,
    required this.onLongPress,
    required this.onLike,
    required this.onDislike,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    int likes = comment.reactions
        .where((r) => r.type == CommentReactionType.like)
        .length;
    CommentReaction? myReaction =
        comment.reactions.where((r) => r.user.id == me.id).firstOrNull;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ProfileImage(
                    user: comment.user,
                    size: 48.0,
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            me.id == comment.user.id
                                ? 'You'
                                : comment.user.firstName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                        Text(
                          timeago.format(comment.createdOn),
                          style: const TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      comment.text,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (comment.lastEditedOn != null) _buildEditedText(),
                        Text(likes.toString()),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onLike,
                          icon: Icon(
                            myReaction?.type == CommentReactionType.like
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 14.0,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onDislike,
                          icon: Icon(
                            myReaction?.type == CommentReactionType.dislike
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                            size: 14.0,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onReport,
                          icon: const Icon(
                            Icons.flag_outlined,
                            size: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditedText() => const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Text(
          'Edited',
          style: TextStyle(
            fontSize: 10.0,
          ),
        ),
      );
}
