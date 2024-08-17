import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';

enum ReactionType { like, love, happy, cheer }

class Reaction extends ModelBase {
  final String user;
  final ReactionType type;

  Reaction({
    required this.user,
    required this.type,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      user: json['user'],
      type: ReactionType.values.firstWhere(
        (element) => element.toString() == 'ReactionType.${json['type']}',
      ),
    );
  }

  String get displayText {
    switch (type) {
      case ReactionType.like:
        return 'Like';
      case ReactionType.love:
        return 'Love';
      case ReactionType.happy:
        return 'Happy';
      case ReactionType.cheer:
        return 'Celebrate';
      default:
        throw UnimplementedError();
    }
  }

  IconData get displayIcon {
    switch (type) {
      case ReactionType.like:
        return Icons.thumb_up;
      case ReactionType.love:
        return Icons.favorite;
      case ReactionType.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case ReactionType.cheer:
        return Icons.emoji_events_rounded;
      default:
        throw UnimplementedError();
    }
  }

  Color get foregroundColor {
    switch (type) {
      case ReactionType.like:
        return const Color(0xFF1976D2);
      case ReactionType.love:
        return const Color(0xFFE53935);
      case ReactionType.happy:
        return const Color(0xFFBA9425);
      case ReactionType.cheer:
        return const Color(0xFF3CB4FF);
      default:
        throw UnimplementedError();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'type': type,
    };
  }

  Reaction deepCopy() {
    return Reaction(
      user: user,
      type: type,
    );
  }

  static String getDisplayText(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return 'Like';
      case ReactionType.love:
        return 'Love';
      case ReactionType.happy:
        return 'Happy';
      case ReactionType.cheer:
        return 'Celebrate';
      default:
        throw UnimplementedError();
    }
  }

  static IconData getDisplayIcon(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return Icons.thumb_up;
      case ReactionType.love:
        return Icons.favorite;
      case ReactionType.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case ReactionType.cheer:
        return Icons.emoji_events_rounded;
      default:
        throw UnimplementedError();
    }
  }

  static Color getForegroundColor(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return const Color(0xFF1976D2);
      case ReactionType.love:
        return const Color(0xFFE53935);
      case ReactionType.happy:
        return const Color(0xFFBA9425);
      case ReactionType.cheer:
        return const Color(0xFF3CB4FF);
      default:
        throw UnimplementedError();
    }
  }
}
