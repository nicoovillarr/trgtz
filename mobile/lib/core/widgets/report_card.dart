import 'package:flutter/material.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/utils.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  const ReportCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) => TCard(
        borderRadius: 4.0,
        elevation: 2.0,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            '/reports/single',
            arguments: report.id,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      report.icon,
                      size: 16.0,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${Utils.capitalize(report.entityType.toString().split('.').last)} reported',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: report.status == ReportStatus.pending
                            ? Colors.orange
                            : report.status == ReportStatus.resolved
                                ? Colors.green
                                : Colors.red,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Text(
                        Utils.capitalize(
                            report.status.toString().split('.').last),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                ReportInfoField(
                  fieldName: 'Date',
                  value: Utils.formatDateTime(report.createdOn),
                ),
                ReportInfoField(
                  fieldName: 'Category',
                  value: Utils.capitalize(report.categoryTitle),
                ),
                ReportInfoField(
                  fieldName: 'Reason',
                  value: report.reason.isNotEmpty ? report.reason : '-',
                ),
              ],
            ),
          ),
        ),
      );
}
