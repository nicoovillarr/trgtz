import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';

class ReportsListProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  List<Report> _reports = [];
  List<Report> get reports => _reports;

  Future populate() async {
    _reports = await _reportService.getReports();
    notifyListeners();
  }
}
