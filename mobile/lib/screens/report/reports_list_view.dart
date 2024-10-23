import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/report/providers/index.dart';

class ReportsListView extends StatefulWidget {
  const ReportsListView({super.key});

  @override
  State<ReportsListView> createState() => _ReportsListViewState();
}

class _ReportsListViewState extends BaseScreen<ReportsListView> {
  ReportsListProvider get viewModel => context.read<ReportsListProvider>();

  @override
  String? get title => 'Reports history';

  @override
  RefreshCallback? get onRefresh => () => loader();

  @override
  void didPopNext() {
    loader().then((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
    });
  }

  @override
  Future loader() async {
    await viewModel.populate();
  }

  @override
  Widget body(BuildContext context) =>
      Selector<ReportsListProvider, List<Report>>(
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
