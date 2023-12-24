import 'package:mobile/models/index.dart';

class Goal extends ModelBase {
  String goalID;
  String title;
  int year;
  DateTime createdOn;
  DateTime? inProgressOn;
  DateTime? completedOn;

  Goal({
    required this.goalID,
    required this.title,
    required this.year,
    required this.createdOn,
    this.inProgressOn,
    this.completedOn,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      goalID: json['goalID'],
      title: json['title'],
      year: json['year'],
      createdOn: ModelBase.tryParseDateTime('createdOn', json)!,
      inProgressOn: ModelBase.tryParseDateTime('inProgressOn', json),
      completedOn: ModelBase.tryParseDateTime('completedOn', json),
    );
  }

  Map<String, dynamic> toJson() => {
        'goalID': goalID,
        'title': title,
        'year': year,
        'createdOn': createdOn.toString(),
        'inProgressOn': inProgressOn.toString(),
        'completedOn': completedOn.toString(),
      };
}
