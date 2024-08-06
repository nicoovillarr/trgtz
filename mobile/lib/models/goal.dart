import 'package:trgtz/models/index.dart';

class Goal extends ModelBase {
  String id;
  String title;
  String? description;
  int year;
  bool canEdit;
  List<Milestone> milestones;
  DateTime createdOn;
  DateTime? completedOn;
  DateTime? deletedOn;

  Goal({
    required this.id,
    required this.title,
    required this.year,
    required this.createdOn,
    this.canEdit = false,
    this.milestones = const [],
    this.description,
    this.completedOn,
    this.deletedOn,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    final milestones =
        json.containsKey('milestones') ? json['milestones'] as List : [];
    return Goal(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      year: json['year'],
      canEdit: json['canEdit'] ?? false,
      milestones:
          milestones.map((milestone) => Milestone.fromJson(milestone)).toList(),
      createdOn: ModelBase.tryParseDateTime('createdOn', json)!,
      completedOn: ModelBase.tryParseDateTime('completedOn', json),
      deletedOn: ModelBase.tryParseDateTime('deletedOn', json),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'year': year,
        'canEdit': canEdit,
        'createdOn': createdOn.toString(),
        'completedOn': completedOn?.toString(),
        'deletedOn': deletedOn?.toString(),
        'milestones':
            milestones.map((milestone) => milestone.toJson()).toList(),
      };

  List<Milestone> getMilestonesSublist({int count = 3}) {
    if (milestones.length <= count) {
      return milestones;
    }

    int lastCompletedIndex =
        milestones.lastIndexWhere((item) => item.completedOn != null);

    if (lastCompletedIndex == -1) {
      return milestones.take(count).toList();
    }

    int startIndex = lastCompletedIndex;
    int endIndex = startIndex + count;

    if (endIndex > milestones.length) {
      startIndex -= endIndex - milestones.length;
      endIndex = milestones.length;
    }

    return milestones.sublist(startIndex, endIndex);
  }

  Goal deepCopy() {
    return Goal(
      id: id,
      title: title,
      description: description,
      year: year,
      canEdit: canEdit,
      milestones: milestones.map((milestone) => milestone.deepCopy()).toList(),
      createdOn: createdOn,
      completedOn: completedOn,
      deletedOn: deletedOn,
    );
  }
}
