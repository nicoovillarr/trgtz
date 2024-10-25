import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/admin/providers/index.dart';

class PendingReportsScreen extends StatefulWidget {
  const PendingReportsScreen({super.key});

  @override
  State<PendingReportsScreen> createState() => _PendingReportsScreenState();
}

class _PendingReportsScreenState extends BaseScreen<PendingReportsScreen> {
  PendingReportsProvider get viewModel => context.read<PendingReportsProvider>();

  @override
  String get title => 'Pending reports';

  @override
  Future afterFirstBuild(BuildContext context) async {
    viewModel.populate();
  }

  @override
  Widget body(BuildContext context) => 
      Selector<PendingReportsProvider, List<Report>>(
        selector: (_, provider) => provider.reports,
        builder: (_, reports, __) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            itemCount: reports.length,
            itemBuilder: (_, index) => ReportCard(report: reports[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
          ),
        ),
      );
}