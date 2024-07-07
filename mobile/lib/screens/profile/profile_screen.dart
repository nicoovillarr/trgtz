import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/profile/services/index.dart';
import 'package:trgtz/store/app_state.dart';
import 'package:trgtz/store/local_storage.dart';
import 'package:trgtz/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends BaseScreen<ProfileScreen> {
  final double _imgSize = 120.0;

  @override
  Widget body(BuildContext context) {
    return StoreConnector<AppState, User?>(
      converter: (store) => store.state.user,
      builder: (context, user) =>
          user != null ? _buildBody(context, user) : _buildNoUserMsg(),
    );
  }

  SingleChildScrollView _buildBody(BuildContext context, User user) =>
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SeparatedColumn(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBaner(context, user),
              _buildOptionsList(
                title: 'Configuration',
                children: [
                  _buildListItem(
                    onTap: _openNameEditor,
                    field: 'Name',
                    icon: Icons.keyboard_arrow_right,
                  ),
                  _buildListItem(
                    onTap: _openEmailEditor,
                    field: 'Email',
                    icon: Icons.keyboard_arrow_right,
                  ),
                ],
              ),
              _buildOptionsList(
                title: 'Security',
                children: [
                  _buildListItem(
                    onTap: _openPasswordEditor,
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

  Widget _buildInfoBaner(BuildContext context, User user) => Row(
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
                        value: 14.toString(),
                        onTap: () {
                          // TODO: Show friends list
                        },
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

  @override
  String? get title => 'Profile';

  void _openNameEditor() {
    Store<AppState> store = StoreProvider.of<AppState>(context);
    String original = store.state.user!.firstName;
    simpleBottomSheet(
      title: 'Change your name',
      child: TextEditModal(
        placeholder: 'John',
        initialValue: original,
        maxLength: 20,
        maxLines: 1,
        validate: (s) =>
            s == null || s.isEmpty ? 'You must enter a name.' : null,
        onSave: (s) {
          setIsLoading(true);
          Store<AppState> store = StoreProvider.of(context);
          User user = store.state.user!;
          user.firstName = s!;
          ModuleService.updateUser(user, store)
              .then((_) => setIsLoading(false))
              .catchError((_) => setIsLoading(false));
        },
      ),
    );
  }

  void _openEmailEditor() {
    Store<AppState> store = StoreProvider.of<AppState>(context);
    String original = store.state.user!.email;
    simpleBottomSheet(
      title: 'Change your email',
      child: TextEditModal(
        placeholder: 'john@email.com',
        initialValue: original,
        maxLength: 150,
        maxLines: 1,
        validate: (s) => s == null || s.isEmpty || !Utils.validateEmail(s)
            ? "You must enter a valid email address."
            : null,
        onSave: (s) {
          setIsLoading(true);
          Store<AppState> store = StoreProvider.of(context);
          User user = store.state.user!;
          user.email = s!;
          ModuleService.updateUser(user, store)
              .then((_) => setIsLoading(false))
              .catchError((_) => setIsLoading(false));
        },
      ),
    );
  }

  void _openPasswordEditor() {
    GlobalKey<FormState> passwordFormKey = GlobalKey();
    GlobalKey<TextEditState> oldPassKey = GlobalKey();
    GlobalKey<TextEditState> newPassKey = GlobalKey();
    GlobalKey<TextEditState> repeatPassKey = GlobalKey();
    simpleBottomSheet(
      title: 'Change your password',
      child: Form(
        key: passwordFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: SeparatedColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 24.0,
            children: [
              TextEdit(
                key: oldPassKey,
                placeholder: 'Current password',
                isPassword: true,
                maxLines: 1,
                validate: (s) => s == null || s.isEmpty
                    ? 'You must enter the current password.'
                    : null,
              ),
              TextEdit(
                key: newPassKey,
                placeholder: 'New password',
                isPassword: true,
                maxLines: 1,
                validate: (s) => s == null || s.isEmpty
                    ? 'You must enter a new password.'
                    : null,
              ),
              TextEdit(
                key: repeatPassKey,
                placeholder: 'Repeat password',
                isPassword: true,
                maxLines: 1,
                validate: (s) {
                  if (s == null || s.isEmpty) {
                    return 'You must repeat the new password.';
                  }
                  if (newPassKey.currentState!.value != s) {
                    return 'Password mismatch.';
                  }
                  return null;
                },
              ),
              MButton(
                onPressed: () async {
                  NavigatorState navigator = Navigator.of(context);
                  if (passwordFormKey.currentState!.validate() &&
                      navigator.canPop()) {
                    String oldPassword = oldPassKey.currentState!.value;
                    String newPassword = newPassKey.currentState!.value;
                    setIsLoading(true);
                    try {
                      await ModuleService.changePassword(
                          oldPassword, newPassword, store);
                      navigator.pop();
                    } catch (e) {
                      showSnackBar(e.toString());
                    } finally {
                      setIsLoading(false);
                    }
                  }
                },
                text: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    LocalStorage.clear().then((_) => Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (route) => false));
  }
}
