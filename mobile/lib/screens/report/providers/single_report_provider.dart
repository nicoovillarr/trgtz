import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/report.service.dart';
import 'package:trgtz/services/websocket.service.dart';

class SingleReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  late Report? _report = null;

  Report? get report => _report;

  Future populate(String id) async {
    _report = await _reportService.getReportById(id);
    notifyListeners();
  }

  Future<void> resolveReport(
          String id, ReportStatus status, String resolution) async =>
      await _reportService.resolveReport(
          id, status.toString().split('.').last, resolution);

  Future<void> deleteEntity(String id) async {}

  void processMessage(WebSocketMessage message) {
    switch (message.type) {
      case broadcastTypeReportUpdate:
        updateGoalField(message.data);
        break;
    }
  }

  void updateGoalField(Map<String, dynamic> fields) {
    if (report == null) {
      return;
    }

    final obj = report!.toJson();
    for (final key in fields.keys) {
      if (key.contains('.')) {
        final keys = key.split('.');
        dynamic current = obj;
        for (int i = 0; i < keys.length - 1; i++) {
          if (int.tryParse(keys[i]) != null) {
            final index = int.parse(keys[i]);
            current = current[index];
          } else {
            current = current[keys[i]];
          }
        }
        final lastKey = keys.last;
        if (int.tryParse(lastKey) != null) {
          final index = int.parse(lastKey);
          current[index] = fields[key];
        } else {
          current[lastKey] = fields[key];
        }
      } else {
        obj[key] = fields[key];
      }
    }

    _report = Report.fromJson(obj);
    notifyListeners();
  }
}
