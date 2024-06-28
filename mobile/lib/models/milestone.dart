import 'package:trgtz/models/index.dart';

class Milestone extends ModelBase {
  String id;
  String title;
  DateTime createdOn;
  DateTime? completedOn;

  Milestone({
    required this.id,
    required this.title,
    required this.createdOn,
    this.completedOn,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['_id'],
      title: json['title'],
      createdOn: ModelBase.tryParseDateTime('createdOn', json)!,
      completedOn: ModelBase.tryParseDateTime('completedOn', json),
    );
  }

  factory Milestone.of({required String title}) =>
      Milestone(id: "", title: title, createdOn: DateTime.now());

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'createdOn': createdOn.toString(),
        'completedOn': completedOn?.toString(),
      };
}
