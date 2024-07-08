import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/store/local_storage.dart';

const String editUserFirstName = 'EDIT_USER_FIRST_NAME';
const String editUserEmail = 'EDIT_USER_EMAIL';
const String editUserPassword = 'EDIT_USER_PASSWORD';

class ProfileFragment extends BaseFragment {
  const ProfileFragment({super.key, required super.enimtAction});

  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends BaseFragmentState<ProfileFragment> {
  final double _imgSize = 120.0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) => state.user != null
          ? _buildBody(
              context,
              state.user!,
              state.friends
                      ?.where((element) =>
                          element.status == 'accepted' &&
                          element.deletedOn == null)
                      .length ??
                  0)
          : _buildNoUserMsg(),
    );
  }

  SingleChildScrollView _buildBody(
          BuildContext context, User user, int friendsCount) =>
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SeparatedColumn(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBaner(context, user, friendsCount),
              _buildOptionsList(
                title: 'Configuration',
                children: [
                  _buildListItem(
                    onTap: () => widget.enimtAction(editUserFirstName),
                    field: 'Name',
                    icon: Icons.keyboard_arrow_right,
                  ),
                  _buildListItem(
                    onTap: () => widget.enimtAction(editUserEmail),
                    field: 'Email',
                    icon: Icons.keyboard_arrow_right,
                  ),
                ],
              ),
              _buildOptionsList(
                title: 'Security',
                children: [
                  _buildListItem(
                    onTap: () => widget.enimtAction(editUserPassword),
                    field: 'Password',
                    icon: Icons.keyboard_arrow_right,
                  ),
                ],
              ),
              _buildOptionsList(
                children: [
                  _buildListItem(
                    onTap: _logout,
                    field: 'Log out',
                    foregroundColor: accentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildOptionsList({
    required List<Widget> children,
    String? title,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          Card(
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) children[i],
              ],
            ),
          ),
        ],
      );

  InkWell _buildListItem({
    required String field,
    required Function() onTap,
    IconData? icon,
    Color foregroundColor = Colors.black,
  }) =>
      InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  field,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: foregroundColor,
                  ),
                ),
              ),
            ),
            if (icon != null)
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  icon,
                  color: foregroundColor,
                ),
              ),
          ],
        ),
      );

  Widget _buildInfoBaner(BuildContext context, User user, int friendsCount) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: _imgSize,
            width: _imgSize,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              border: Border.all(
                color: Theme.of(context).shadowColor.withOpacity(0.25),
                width: 2.0,
              ),
            ),
            child: InkWell(
              onTap: () {},
              child: const Placeholder(),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: SizedBox(
              height: _imgSize,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.firstName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    user.email,
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  Row(
                    children: [
                      _buildInfoStat(
                        title: 'Friends',
                        value: friendsCount.toString(),
                        onTap: () =>
                            Navigator.of(context).pushNamed('/friends'),
                      ),
                      const SizedBox(width: 8.0),
                      _buildInfoStat(
                        title: 'Goals',
                        value: 3.toString(),
                        onTap: () {
                          // TODO: Show goals statistics
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildInfoStat({
    required String title,
    required String value,
    required Function() onTap,
  }) =>
      Expanded(
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildNoUserMsg() => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'There was a problem when loading your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
            ),
          ),
        ),
      );

  void _logout() {
    LocalStorage.clear().then((_) => Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (route) => false));
  }
}
