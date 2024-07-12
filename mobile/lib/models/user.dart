import 'package:trgtz/models/index.dart';

class User extends ModelBase {
  String id;
  String firstName;
  String email;

  User({
    required this.id,
    required this.firstName,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['_id'], firstName: json['firstName'], email: json['email']);
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'email': email,
      };
}
