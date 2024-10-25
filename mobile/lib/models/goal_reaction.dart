import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';

enum GoalReactionType { like, love, happy, cheer }

class GoalReaction extends ReactionBase<GoalReactionType> {
  GoalReaction({
    required super.id,
    required super.user,
    required super.type,
  });

  factory GoalReaction.fromJson(Map<String, dynamic> json) {
    return GoalReaction(
      id: json['_id'],
      user: User.fromJson(json['user']),
      type: ModelBase.enumFromString(GoalReactionType.values, json['type']),
    );
  }

  @override
  String get displayText {
    switch (type) {
      case GoalReactionType.like:
        return 'Like';
      case GoalReactionType.love:
        return 'Love';
      case GoalReactionType.happy:
        return 'Happy';
      case GoalReactionType.cheer:
        return 'Celebrate';
      default:
        throw UnimplementedError();
    }
  }

  @override
  IconData get displayIcon {
    switch (type) {
      case GoalReactionType.like:
        return Icons.thumb_up;
      case GoalReactionType.love:
        return Icons.favorite;
      case GoalReactionType.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case GoalReactionType.cheer:
        return Icons.emoji_events_rounded;
      default:
        throw UnimplementedError();
    }
  }

  @override
  Color get foregroundColor {
    switch (type) {
      case GoalReactionType.like:
        return const Color(0xFF1976D2);
      case GoalReactionType.love:
        return const Color(0xFFE53935);
      case GoalReactionType.happy:
        return const Color(0xFFBA9425);
      case GoalReactionType.cheer:
        return const Color(0xFF3CB4FF);
      default:
        throw UnimplementedError();
    }
  }

  @override
  GoalReaction deepCopy() {
    return GoalReaction(
      id: id,
      user: user.deepCopy(),
      type: type,
    );
  }

  static String getDisplayText(GoalReactionType type) {
    switch (type) {
      case GoalReactionType.like:
        return 'Like';
      case GoalReactionType.love:
        return 'Love';
      case GoalReactionType.happy:
        return 'Happy';
      case GoalReactionType.cheer:
        return 'Celebrate';
      default:
        throw UnimplementedError();
    }
  }

  static IconData getDisplayIcon(GoalReactionType type) {
    switch (type) {
      case GoalReactionType.like:
        return Icons.thumb_up;
      case GoalReactionType.love:
        return Icons.favorite;
      case GoalReactionType.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case GoalReactionType.cheer:
        return Icons.emoji_events_rounded;
      default:
        throw UnimplementedError();
    }
  }

  static Color getForegroundColor(GoalReactionType type) {
    switch (type) {
      case GoalReactionType.like:
        return const Color(0xFF1976D2);
      case GoalReactionType.love:
        return const Color(0xFFE53935);
      case GoalReactionType.happy:
        return const Color(0xFFBA9425);
      case GoalReactionType.cheer:
        return const Color(0xFF3CB4FF);
      default:
        throw UnimplementedError();
    }
  }
}
