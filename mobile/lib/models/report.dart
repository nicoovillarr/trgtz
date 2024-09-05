import 'package:trgtz/models/index.dart';

enum ReportCategory { spam, harassment, hateSpeech, violence, nudity, other }

enum ReportStatus {
  pending,
  approved,
  rejected,
}

class Report extends ModelBase {
  String id;
  User user;
  String entityType;
  String entityId;
  ReportCategory category;
  String reason;
  ReportStatus status;
  String resolution;

  Report({
    required this.id,
    required this.user,
    required this.entityType,
    required this.entityId,
    required this.category,
    required this.reason,
    required this.status,
    required this.resolution,
  });

  String get displayText => Report.getDisplayText(category);

  String get categoryDescription => Report.getCategoryDescription(category);

  String get statusText => Report.getStatusText(status);

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'],
      user: User.fromJson(json['user']),
      entityType: json['entityType'],
      entityId: json['entityId'],
      category: ReportCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      reason: json['reason'],
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      resolution: json['resolution'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user': user.toJson(),
        'entityType': entityType,
        'entityId': entityId,
        'category': category.toString().split('.').last,
        'reason': reason,
        'status': status.toString().split('.').last,
        'resolution': resolution,
      };

  Report deepCopy() => Report(
        id: id,
        user: user.deepCopy(),
        entityType: entityType,
        entityId: entityId,
        category: category,
        reason: reason,
        status: status,
        resolution: resolution,
      );

  static String getDisplayText(ReportCategory category) {
    switch (category) {
      case ReportCategory.spam:
        return 'Spam';
      case ReportCategory.harassment:
        return 'Harassment';
      case ReportCategory.hateSpeech:
        return 'Hate Speech';
      case ReportCategory.violence:
        return 'Violence';
      case ReportCategory.nudity:
        return 'Nudity';
      case ReportCategory.other:
        return 'Other';
      default:
        throw UnimplementedError();
    }
  }

  static String getCategoryDescription(ReportCategory category) {
    switch (category) {
      case ReportCategory.spam:
        return 'Unwanted or repetitive content that disrupts the user experience, including unsolicited messages, advertisements, or links.';
      case ReportCategory.harassment:
        return 'Aggressive or inappropriate behavior directed at an individual or group, including bullying, threats, or repeated unwanted contact.';
      case ReportCategory.hateSpeech:
        return 'Content that promotes or incites violence, hostility, or discrimination against individuals or groups based on race, religion, gender, sexual orientation, or other protected characteristics.';
      case ReportCategory.violence:
        return 'Content that glorifies, promotes, or depicts violence, physical harm, or abuse against individuals, animals, or property.';
      case ReportCategory.nudity:
        return 'Explicit or inappropriate content featuring nudity or sexual activity that violates community standards.';
      case ReportCategory.other:
        return 'Any other content that violates community guidelines or terms of service.';
      default:
        throw UnimplementedError();
    }
  }

  static String getStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.approved:
        return 'Approved';
      case ReportStatus.rejected:
        return 'Rejected';
      default:
        throw UnimplementedError();
    }
  }

  static List<ReportCategory> forComment() => [
        ReportCategory.spam,
        ReportCategory.harassment,
        ReportCategory.hateSpeech,
        ReportCategory.violence,
        ReportCategory.nudity,
        ReportCategory.other,
      ];
}
