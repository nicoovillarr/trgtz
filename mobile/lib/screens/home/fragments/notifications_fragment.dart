import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsFragment extends BaseFragment {
  const NotificationsFragment({super.key, required super.enimtAction});

  @override
  State<NotificationsFragment> createState() => _NotificationsFragmentState();
}

class _NotificationsFragmentState
    extends BaseFragmentState<NotificationsFragment> {
  @override
  void customInitState() {}

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, List<Alert>>(
        converter: (store) => store.state.alerts ?? [],
        builder: (context, alerts) => ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) => _buildNotificationRow(alerts[index]),
        ),
      );

  Widget _buildNotificationRow(Alert alert) => ListTile(
        onTap: () {},
        title: Row(
          children: [
            Expanded(
              child: Text(
                alert.sentBy.firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              timeago.format(alert.createdOn),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Text(Utils.getAlertMessage(alert.type)),
        leading: CircleAvatar(
          child: Text(alert.sentBy.firstName[0]),
        ),
      );
}
