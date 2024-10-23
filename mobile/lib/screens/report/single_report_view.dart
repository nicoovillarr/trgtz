import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/report/providers/index.dart';
import 'package:trgtz/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class SingleReportView extends StatefulWidget {
  const SingleReportView({super.key});

  @override
  State<SingleReportView> createState() => _SingleReportViewState();
}

class _SingleReportViewState extends BaseScreen<SingleReportView> {
  SingleReportProvider get viewModel => context.read<SingleReportProvider>();

  @override
  String? get title => 'Report details';

  @override
  RefreshCallback? get onRefresh => () => loader();

  @override
  FloatingActionButton? get fab =>
      user!.isSuperAdmin && viewModel.report?.resolvedOn == null
          ? FloatingActionButton.extended(
              onPressed: _showResolutionDialog,
              label: const Text('Resolve report'),
            )
          : null;

  @override
  Future afterFirstBuild(BuildContext context) async {
    subscribeToChannel('REPORT', viewModel.report!.id, (message) {
      viewModel.processMessage(message);
      setState(() {});
    });
  }

  @override
  Future loader() async {
    final reportId = ModalRoute.of(context)!.settings.arguments as String;
    await viewModel.populate(reportId);
  }

  @override
  Widget body(BuildContext context) => Selector<SingleReportProvider, Report?>(
        selector: (_, provider) => provider.report,
        builder: (_, report, __) => report != null
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SeparatedColumn(
                    spacing: 8.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportSummary(report),
                      const Divider(),
                      _buildReportedEntityContainer(report),
                      if (user!.isSuperAdmin) _buildReportedUserInfo(report),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      );

  Widget _buildReportSummary(Report report) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportInfoField(fieldName: 'ID', value: report.id),
          ReportInfoField(fieldName: 'Type', value: report.entityTypeText),
          ReportInfoField(
              fieldName: 'Date', value: Utils.formatDateTime(report.createdOn)),
          ReportInfoField(
              fieldName: 'Category',
              value: Utils.capitalize(report.categoryTitle)),
          ReportInfoField(
              fieldName: 'Reason',
              value: report.reason.isNotEmpty ? report.reason : '-'),
          ReportInfoField(fieldName: 'Reported by', value: report.user.email),
        ],
      );

  Widget _buildReportedEntityContainer(Report report) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reported entity',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          _buildReportedEntity(report),
        ],
      );

  Widget _buildReportedEntity(Report report) {
    switch (report.entityType) {
      case ReportEntityType.user:
        User user = User.fromJson(report.entity);
        return _buildReportedUser(user);
      case ReportEntityType.goal:
        return _buildReportedGoal(report);
      case ReportEntityType.comment:
        return _buildReportedComment(report);
      default:
        return const SizedBox();
    }
  }

  Widget _buildReportedGoal(Report report) {
    Map<String, dynamic> entity = report.entity;
    return ReportInfoCard(
      icon: const Icon(
        Icons.flag_outlined,
        color: Colors.blue,
      ),
      title: Text(
        entity['title'],
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        entity['description'] != null &&
                entity['description'].toString().isNotEmpty
            ? entity['description']
            : '-',
      ),
    );
  }

  Widget _buildReportedUserInfo(Report report) {
    final User user = User.fromJson(report.entityType == ReportEntityType.user
        ? report.entity
        : report.entity['user']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Reported user',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8.0),
        ReportInfoCard(
          icon: Row(
            children: [
              ProfileImage(
                user: user,
                borderRadius: 8.0,
                size: 40.0,
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.firstName,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(user.email),
                ],
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Joined on ${Utils.formatDate(user.createdOn)}'),
              Row(
                children: [
                  const Expanded(child: Text('Previous violations: ${0}')),
                  Text(
                    '#${user.id}',
                    style: TextStyle(color: mainColor.withOpacity(0.65)),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportedUser(User user) => ReportInfoCard(
        icon: Row(
          children: [
            ProfileImage(
              user: user,
              borderRadius: 8.0,
              size: 40.0,
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.firstName,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("#${user.id}"),
              ],
            ),
          ],
        ),
      );

  Widget _buildReportedComment(Report report) {
    Map<String, dynamic> entity = report.entity;
    return ReportInfoCard(
      icon: const Icon(
        Icons.message_outlined,
        color: Colors.blue,
      ),
      title: Text(entity['text']),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            timeago.format(ModelBase.tryParseDateTime('createdOn', entity)!),
            style: TextStyle(
              fontSize: 10.0,
              color: mainColor.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  void _showResolutionDialog() {
    simpleBottomSheet(
      height: MediaQuery.of(context).size.height * 0.95,
      builder: (context, _) =>
          ReportResolutionDialog(onResolution: (status, reason, setError) {
        viewModel
            .resolveReport(
          viewModel.report!.id,
          status,
          reason,
        )
            .then((_) {
          showSnackBar('Report resolved successfully');
          Navigator.of(context).pop();
        }).catchError((error) {
          setError(error.toString());
        });
      }),
    );
  }
}
