import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/store/index.dart';

const String setProfileImage = 'SET_PROFILE_IMAGE';
const String editUserFirstName = 'EDIT_USER_FIRST_NAME';
const String editUserEmail = 'EDIT_USER_EMAIL';
const String editUserPassword = 'EDIT_USER_PASSWORD';
const String logout = 'LOGOUT';

class ProfileFragment extends BaseFragment {
  const ProfileFragment({super.key, required super.enimtAction});

  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends BaseFragmentState<ProfileFragment> {
  final double _imgSize = 120.0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Map<String, dynamic>>(
      converter: (store) => {
        "user": store.state.user,
        "friends": store.state.friends,
      },
      builder: (context, state) => state["user"] != null
          ? _buildBody(
              context,
              state["user"]!,
              state["friends"]
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
                  ),
                  _buildListItem(
                    onTap: () => widget.enimtAction(editUserEmail),
                    field: 'Email',
                  ),
                  _buildListItem(
                    onTap: () {},
                    field: 'Notifications',
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
                  ),
                ],
              ),
              _buildOptionsList(
                children: [
                  _buildListItem(
                    onTap: () => widget.enimtAction(logout),
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
          TCard(
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) children[i],
              ],
            ),
          ),
        ],
      );

  Widget _buildListItem({
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
              Padding(
                padding: const EdgeInsets.only(
                  right: 16.0,
                  left: 4.0,
                ),
                child: Icon(
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
          Stack(
            children: [
              SizedBox(
                height: _imgSize,
                width: _imgSize,
                child: ProfileImage(
                  user: user,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(0, 2.0),
                        )
                      ]),
                  child: IconButton(
                    onPressed: () => widget.enimtAction(setProfileImage),
                    icon: const Icon(
                      Icons.edit,
                      size: 16.0,
                    ),
                  ),
                ),
              ),
            ],
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
}
