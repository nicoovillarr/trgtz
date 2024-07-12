import 'package:trgtz/models/index.dart';

class Alert extends ModelBase {
  String id;
  User sentBy;
  String type;
  bool seen;
  DateTime createdOn;

  Alert({
    required this.id,
    required this.sentBy,
    required this.type,
    required this.seen,
    required this.createdOn,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['_id'],
      sentBy: User.fromJson(json['sent_by']),
      type: json['type'],
      seen: json['seen'],
      createdOn: DateTime.parse(json['createdOn']),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'sentBy': sentBy.toJson(),
        'type': type,
        'seen': seen,
        'createdOn': createdOn.toIso8601String(),
      };
}
