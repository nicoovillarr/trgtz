import 'package:trgtz/models/index.dart';

class User extends ModelBase {
  String id;
  String firstName;
  String email;
  DateTime createdOn;
  Image? avatar;

  User({
    required this.id,
    required this.firstName,
    required this.email,
    required this.createdOn,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'],
      email: json['email'],
      createdOn: ModelBase.tryParseDateTime('createdAt', json)!,
      avatar: json['avatar'] != null ? Image.fromJson(json['avatar']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'email': email,
        'createdAt': createdOn.toIso8601String(),
        'avatar': avatar?.toJson(),
      };

  User deepCopy() {
    return User(
      id: id,
      firstName: firstName,
      createdOn: createdOn,
      email: email,
    );
  }
}
