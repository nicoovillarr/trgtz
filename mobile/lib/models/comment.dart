import 'package:trgtz/models/index.dart';

class Comment extends ModelBase {
  final String id;
  final String text;
  final User user;
  final DateTime createdOn;

  Comment({
    required this.id,
    required this.text,
    required this.user,
    required this.createdOn,
  });

  factory Comment.fromJson(Map<String, dynamic> map) {
    return Comment(
      id: map['_id'],
      text: map['text'],
      user: User.fromJson(map['user']),
      createdOn: ModelBase.tryParseDateTime('createdOn', map)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'user': user.toJson(),
      'createdOn': createdOn,
    };
  }

  Comment deepCopy() {
    return Comment(
      id: id,
      text: text,
      user: user.deepCopy(),
      createdOn: createdOn,
    );
  }
}
