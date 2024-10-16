import 'package:trgtz/models/index.dart';

enum AuthProvider {
  email,
  google,
}

class User extends ModelBase {
  String id;
  String firstName;
  String email;
  DateTime createdOn;
  Image? avatar;
  List<AuthProvider> authProviders;

  User({
    required this.id,
    required this.firstName,
    required this.email,
    required this.createdOn,
    this.avatar,
    this.authProviders = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'],
      email: json['email'],
      createdOn: ModelBase.tryParseDateTime('createdAt', json)!,
      avatar: json['avatar'] != null ? Image.fromJson(json['avatar']) : null,
      authProviders: json['providers'] != null
          ? List<AuthProvider>.from(json['providers'].map((provider) =>
              ModelBase.enumFromString(AuthProvider.values, provider)))
          : [],
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

  User copyWith({
    String? id,
    String? firstName,
    String? email,
    DateTime? createdOn,
    Image? avatar,
    List<AuthProvider>? authProviders,
  }) =>
      User(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        email: email ?? this.email,
        createdOn: createdOn ?? this.createdOn,
        avatar: avatar ?? this.avatar,
        authProviders: authProviders ?? this.authProviders,
      );
}
