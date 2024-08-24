import 'package:flutter/material.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool mine;
  const CommentCard({
    super.key,
    required this.comment,
    required this.mine,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () {},
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                mine ? 'You' : comment.user.firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              timeago.format(comment.createdOn),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Text(comment.text),
        leading: ProfileImage(
          user: comment.user,
        ),
      );
}
