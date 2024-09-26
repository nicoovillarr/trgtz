import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/utils.dart';

enum ReportEntityType { comment, goal, user }

enum ReportCategory { spam, harassment, hateSpeech, violence, nudity, other }

enum ReportStatus {
  pending,
  approved,
  rejected,
}

class Report extends ModelBase {
  String id;
  User user;
  ReportEntityType entityType;
  String entityId;
  ReportCategory category;
  String reason;
  ReportStatus status;
  String? resolution;
  DateTime createdOn;
  DateTime? resolvedOn;

  Map<String, dynamic> entity;

  Report({
    required this.id,
    required this.user,
    required this.entityType,
    required this.entityId,
    required this.category,
    required this.reason,
    required this.status,
    this.resolution,
    required this.createdOn,
    this.resolvedOn,
    required this.entity,
  });

  String get categoryTitle => Report.getCategoryTytle(category);

  String get categoryDescription => Report.getCategoryDescription(category);

  String get statusText => Report.getStatusText(status);

  String get entityTypeText => Report.getEntityTypeText(entityType);

  IconData get icon => Report.getIcon(entityType);

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'],
      user: User.fromJson(json['user']),
      entityType: ReportEntityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['entity_type'],
      ),
      entityId: json['entity_id'],
      category: ReportCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      reason: json['reason'],
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      resolution: json['resolution'],
      createdOn: ModelBase.tryParseDateTime('createdOn', json)!,
      resolvedOn: ModelBase.tryParseDateTime('resolvedOn', json),
      entity: json['entity'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user': user.toJson(),
        'entityType': entityType.toString().split('.').last,
        'entityId': entityId,
        'category': category.toString().split('.').last,
        'reason': reason,
        'status': status.toString().split('.').last,
        'resolution': resolution,
        'createdOn': createdOn.toIso8601String(),
        'resolvedOn': resolvedOn?.toIso8601String(),
        'entity': entity,
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
        createdOn: createdOn,
        resolvedOn: resolvedOn,
        entity: entity,
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

  static List<ReportCategory> forGoal() => [
        ReportCategory.spam,
        ReportCategory.harassment,
        ReportCategory.hateSpeech,
        ReportCategory.violence,
        ReportCategory.nudity,
        ReportCategory.other,
      ];

  static String getCategoryTytle(ReportCategory category) {
    String cat = category.toString().split('.').last;
    String categoryTitle = '';
    for (int i = 0; i < cat.length; i++) {
      if (cat[i].toUpperCase() == cat[i]) {
        categoryTitle += ' ';
      }
      categoryTitle += cat[i];
    }
    return categoryTitle.trim();
  }

  static String getEntityTypeText(ReportEntityType entityType) =>
      Utils.capitalize(entityType.toString().split('.').last);

  static IconData getIcon(ReportEntityType entityType) {
    switch (entityType) {
      case ReportEntityType.comment:
        return Icons.comment_outlined;
      case ReportEntityType.goal:
        return Icons.flag_outlined;
      case ReportEntityType.user:
        return Icons.person_outline;
      default:
        throw UnimplementedError();
    }
  }
}
