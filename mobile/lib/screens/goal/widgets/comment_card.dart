import 'package:flutter/material.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool mine;
  final Function() onLongPress;
  const CommentCard({
    super.key,
    required this.comment,
    required this.mine,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Container(
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
                              mine ? 'You' : comment.user.firstName,
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
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {},
                            icon: const Icon(
                              Icons.thumb_up_outlined,
                              size: 14.0,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {},
                            icon: const Icon(
                              Icons.thumb_down_outlined,
                              size: 14.0,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {},
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
