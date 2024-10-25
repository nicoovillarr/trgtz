import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';

enum CommentReactionType { like, dislike }

class CommentReaction extends ReactionBase<CommentReactionType> {
  CommentReaction({
    required super.id,
    required super.user,
    required super.type,
  });

  factory CommentReaction.fromJson(Map<String, dynamic> json) {
    return CommentReaction(
      id: json['_id'],
      user: User.fromJson(json['user']),
      type:
          ModelBase.enumFromString(CommentReactionType.values, json['type']),
    );
  }

  @override
  String get displayText {
    switch (type) {
      case CommentReactionType.like:
        return 'Like';
      case CommentReactionType.dislike:
        return 'Dislike';
      default:
        throw UnimplementedError();
    }
  }

  @override
  IconData get displayIcon {
    switch (type) {
      case CommentReactionType.like:
        return Icons.thumb_up;
      case CommentReactionType.dislike:
        return Icons.thumb_down;
      default:
        throw UnimplementedError();
    }
  }

  @override
  Color get foregroundColor {
    switch (type) {
      case CommentReactionType.like:
        return const Color(0xFF1976D2);
      case CommentReactionType.dislike:
        return const Color(0xFFE53935);
      default:
        throw UnimplementedError();
    }
  }

  @override
  CommentReaction deepCopy() {
    return CommentReaction(
      id: id,
      user: user.deepCopy(),
      type: type,
    );
  }

  static String getDisplayText(CommentReactionType type) {
    switch (type) {
      case CommentReactionType.like:
        return 'Like';
      case CommentReactionType.dislike:
        return 'Dislike';
      default:
        throw UnimplementedError();
    }
  }

  static IconData getDisplayIcon(CommentReactionType type) {
    switch (type) {
      case CommentReactionType.like:
        return Icons.thumb_up;
      case CommentReactionType.dislike:
        return Icons.thumb_down;
      default:
        throw UnimplementedError();
    }
  }

  static Color getForegroundColor(CommentReactionType type) {
    switch (type) {
      case CommentReactionType.like:
        return const Color(0xFF1976D2);
      case CommentReactionType.dislike:
        return const Color(0xFFE53935);
      default:
        throw UnimplementedError();
    }
  }
}
