import 'package:trgtz/models/index.dart';

class View implements ModelBase {
  final User user;
  final DateTime viewedOn;

  const View({
    required this.user,
    required this.viewedOn,
  });

  factory View.fromJson(Map<String, dynamic> json) {
    return View(
      user: User.fromJson(json['user']),
      viewedOn: ModelBase.tryParseDateTime('viewedOn', json)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'viewedOn': viewedOn.toIso8601String(),
    };
  }

  View deepCopy() {
    return View(
      user: user.deepCopy(),
      viewedOn: viewedOn,
    );
  }
}
