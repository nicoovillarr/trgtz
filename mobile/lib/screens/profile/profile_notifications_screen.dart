import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/base_screen.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/screens/profile/providers/index.dart';

class ProfileNotificationsScreen extends StatefulWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  State<ProfileNotificationsScreen> createState() =>
      _ProfileNotificationsScreenState();
}

class _ProfileNotificationsScreenState
    extends BaseScreen<ProfileNotificationsScreen> {
  ProfileNotificationsProvider get viewModel =>
      context.read<ProfileNotificationsProvider>();

  @override
  String? get title => 'Notifications';

  @override
  void initSubscriptions() {
    subscribeToChannel(broadcastChannelTypeUser, store.state.user!.id, viewModel.processMessage);
  }

  @override
  Future loader() async {
    await viewModel.populate();
  }

  @override
  Widget body(BuildContext context) =>
      Selector<ProfileNotificationsProvider, List<ProfileNotificationsModel>>(
        selector: (_, provider) => provider.notifications,
        builder: (_, notifications, __) => SingleChildScrollView(
          child: Column(children: [
            _buildTypesBlock('Push Notifications', notifications),
          ]),
        ),
      );

  Widget _buildTypesBlock(
          String title, List<ProfileNotificationsModel> items) =>
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            TCard(
              child: Column(
                children: items.map(_buildTypeItem).toList(),
              ),
            ),
          ],
        ),
      );

  Widget _buildTypeItem(ProfileNotificationsModel item) => SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        title: Text(item.displayText, style: TextStyle(fontSize: 14)),
        value: item.isEnabled,
        onChanged: (value) => viewModel.toggle(item.key, value),
      );
}
