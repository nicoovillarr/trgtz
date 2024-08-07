import 'package:trgtz/models/index.dart';

class Image implements ModelBase {
  final String id;
  final String url;
  final DateTime createdOn;

  const Image({
    required this.id,
    required this.url,
    required this.createdOn,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['_id'],
      url: json['url'],
      createdOn: DateTime.parse(json['createdOn']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'url': url,
      'createdOn': createdOn.toIso8601String(),
    };
  }
}
