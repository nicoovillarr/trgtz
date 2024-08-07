import 'package:trgtz/models/index.dart';

class Event extends ModelBase {
  final String id;
  final String type;
  final DateTime createdOn;

  Event({
    required this.id,
    required this.type,
    required this.createdOn,
  });

  String get displayText {
    switch (type) {
      case 'goal_created':
        return 'Goal created';
      case 'goal_updated':
        return 'Goal updated';
      case 'goal_completed':
        return 'Goal completed';
      case 'milestone_created':
        return 'Milestone created';
      case 'milestone_completed':
        return 'Milestone completed';
      default:
        return 'Unknown';
    }
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      type: json['type'],
      createdOn: ModelBase.tryParseDateTime('createdOn', json)!,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'createdOn': createdOn.toString(),
      };

  Event deepCopy() => Event(
        id: id,
        type: type,
        createdOn: createdOn,
      );
}
