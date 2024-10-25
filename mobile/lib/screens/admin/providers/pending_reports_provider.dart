import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';

class PendingReportsProvider extends ChangeNotifier {

  List<Report> _reports = [];

  List<Report> get reports => _reports;

  Future populate() async {
    ReportService reportService = ReportService();
    _reports = await reportService.getAdminReports();
    notifyListeners();
  }

}