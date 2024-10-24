import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

const String goFriends = 'GO_FRIENDS';

class NotificationsFragment extends BaseFragment {
  const NotificationsFragment({super.key, required super.enimtAction});

  @override
  State<NotificationsFragment> createState() => _NotificationsFragmentState();
}

class _NotificationsFragmentState
    extends BaseFragmentState<NotificationsFragment> {
  @override
  Widget build(BuildContext context) => StoreConnector<ApplicationState, List<Alert>>(
        converter: (store) => store.state.alerts ?? [],
        builder: (context, alerts) => ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) => _buildNotificationRow(alerts[index]),
        ),
      );

  Widget _buildNotificationRow(Alert alert) => ListTile(
        onTap: () {
          if (alert.type.startsWith('friend_')) {
            widget.enimtAction(goFriends);
          }
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!alert.seen)
              Container(
                margin: const EdgeInsets.only(left: 5, right: 5),
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                alert.sentBy.id == store.state.user!.id
                    ? 'System'
                    : alert.sentBy.firstName,
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
        subtitle: Text(Utils.getAlertMessage(alert.sentBy, alert.type)),
        leading: alert.sentBy.id != store.state.user!.id
            ? ProfileImage(
                user: alert.sentBy,
              )
            : null,
      );
}
