import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';

abstract class ReactionBase<T> extends ModelBase {
  final String id;
  final User user;
  final T type;

  ReactionBase({
    required this.id,
    required this.user,
    required this.type,
  });

  String get displayText;
  IconData get displayIcon;
  Color get foregroundColor;

  static T enumFromString<T>(List<T> enumValues, String enumString) {
    return enumValues.firstWhere(
      (e) => e.toString().split('.').last == enumString,
      orElse: () => throw ArgumentError('Invalid enum value: $enumString'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'type': type.toString().split('.').last,
    };
  }

  ReactionBase<T> deepCopy();

  static String getDisplayText<T>(T type) {
    throw UnimplementedError();
  }

  static IconData getDisplayIcon<T>(T type) {
    throw UnimplementedError();
  }

  static Color getForegroundColor<T>(T type) {
    throw UnimplementedError();
  }
}
