import 'package:trgtz/models/index.dart';

class Goal extends ModelBase {
  String goalID;
  String title;
  String? description;
  int year;
  DateTime createdOn;
  DateTime? completedOn;
  DateTime? deletedOn;

  Goal({
    required this.goalID,
    required this.title,
    required this.year,
    required this.createdOn,
    this.description,
    this.completedOn,
    this.deletedOn,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      goalID: json['goalID'],
      title: json['title'],
      description: json['description'],
      year: json['year'],
      createdOn: ModelBase.tryParseDateTime('createdOn', json)!,
      completedOn: ModelBase.tryParseDateTime('completedOn', json),
      deletedOn: ModelBase.tryParseDateTime('deletedOn', json),
    );
  }

  Map<String, dynamic> toJson() => {
        'goalID': goalID,
        'title': title,
        'description': description,
        'year': year,
        'createdOn': createdOn.toString(),
        'completedOn': completedOn.toString(),
        'deletedOn': deletedOn.toString(),
      };
}
