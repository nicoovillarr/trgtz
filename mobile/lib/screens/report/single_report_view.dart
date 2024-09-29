import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/report/providers/index.dart';
import 'package:trgtz/screens/report/widgets/index.dart';
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
  Future afterFirstBuild(BuildContext context) async {
    final reportId = ModalRoute.of(context)!.settings.arguments as String;
    viewModel.populate(reportId).then((_) => setState(() {}));
  }

  @override
  Widget body(BuildContext context) => Selector<SingleReportProvider, Report?>(
        selector: (_, provider) => provider.report,
        builder: (_, report, __) => report != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: SeparatedColumn(
                  spacing: 8.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReportSummary(report),
                    const Divider(),
                    _buildReportedEntityContainer(report),
                  ],
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

  // Column _buildReportedUser(User user) {
  //   return Column(
  //       children: [
  //         ReportInfoField(fieldName: 'ID', value: user.id),
  //         ReportInfoField(fieldName: 'Name', value: user.firstName),
  //         ReportInfoField(fieldName: 'Email', value: user.email),
  //         ReportInfoField(
  //             fieldName: 'Joined on',
  //             value: Utils.formatDateTime(user.createdOn)),
  //       ],
  //     );
  // }

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
}
