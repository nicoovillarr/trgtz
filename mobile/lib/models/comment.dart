import 'package:trgtz/models/index.dart';

class Comment extends ModelBase {
  final String id;
  final String text;
  final User user;
  final DateTime createdOn;
  final DateTime? lastEditedOn;
  final List<CommentReaction> reactions;

  Comment({
    required this.id,
    required this.text,
    required this.user,
    required this.createdOn,
    this.lastEditedOn,
    this.reactions = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> map) {
    final reactions =
        map.containsKey('reactions') ? (map['reactions'] as List) : [];

    return Comment(
      id: map['_id'],
      text: map['text'],
      user: User.fromJson(map['user']),
      createdOn: ModelBase.tryParseDateTime('createdOn', map)!,
      lastEditedOn: ModelBase.tryParseDateTime('lastEditedOn', map),
      reactions: reactions
          .map((reaction) => CommentReaction.fromJson(reaction))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'user': user.toJson(),
      'createdOn': createdOn.toString(),
      'lastEditedOn': lastEditedOn?.toString(),
    };
  }

  Comment deepCopy() {
    return Comment(
      id: id,
      text: text,
      user: user.deepCopy(),
      createdOn: createdOn,
      lastEditedOn: lastEditedOn,
    );
  }
}
