import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/report.service.dart';

class SingleReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  late Report? _report = null;
  Report? get report => _report;

  Future populate(String id) async {
    _report = await _reportService.getReportById(id);
    notifyListeners();
  }
}
