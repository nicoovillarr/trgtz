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
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.top,
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
          subtitle: Text(
            comment.text,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
          leading: SizedBox(
            width: 40,
            child: ProfileImage(
              user: comment.user,
            ),
          ),
        ),
      );
}
