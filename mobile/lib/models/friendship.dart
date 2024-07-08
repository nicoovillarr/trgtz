import 'package:trgtz/models/index.dart';

class Friendship extends ModelBase {
  String requester;
  String recipient;
  String status;
  DateTime createdOn;
  DateTime? updatedOn;
  DateTime? deletedOn;

  User friendDetails;

  Friendship({
    required this.requester,
    required this.recipient,
    required this.status,
    required this.createdOn,
    this.updatedOn,
    this.deletedOn,
    required this.friendDetails,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      requester: json['requester'],
      recipient: json['recipient'],
      status: json['status'],
      createdOn: ModelBase.tryParseDateTime('createdOn', json)!,
      updatedOn: ModelBase.tryParseDateTime('updatedOn', json),
      deletedOn: ModelBase.tryParseDateTime('deletedOn', json),
      friendDetails: User.fromJson(json['friendDetails']),
    );
  }

  Map<String, dynamic> toJson() => {
        'requester': requester,
        'recipient': recipient,
        'status': status,
        'createdOn': createdOn.toIso8601String(),
        'updatedOn': updatedOn?.toIso8601String(),
        'deletedOn': deletedOn?.toIso8601String(),
        'friendDetails': friendDetails.toJson(),
      };

  String get otherUserId =>
      requester != friendDetails.id ? recipient : requester;
}
