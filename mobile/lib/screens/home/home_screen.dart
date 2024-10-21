import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/home/fragments/index.dart';
import 'package:trgtz/screens/home/services/index.dart';
import 'package:trgtz/security.dart';
import 'package:trgtz/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/utils.dart';
import 'package:uuid/uuid.dart';

GlobalKey<HomeScreenState> homeScreenKey = GlobalKey();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends BaseScreen<HomeScreen> {
  int _currentIndex = 1;
  late List<Widget> _fragments;

  final picker = ImagePicker();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    _fragments = [
      NotificationsFragment(enimtAction: _processAlertsAction),
      DashboardFragment(enimtAction: _processProfileAction),
      ProfileFragment(enimtAction: _processProfileAction),
    ];

    super.initState();
  }

  @override
  Future afterFirstBuild(BuildContext context) async {
    subscribeToChannel(broadcastChannelTypeUser, store.state.user!.id,
        (message) {
      switch (message.type) {
        case broadcastTypeUserUpdate:
          store.dispatch(UpdateUserFields(fields: message.data));
          setState(() {});
          break;

        case broadcastTypeUserEmailVerified:
          store.dispatch(SetUserEmailVerifiedAction(isEmailVerified: message.data));
          setState(() {});

          if (message.data) {
            showSnackBar('Your email has been verified!');
          }
          break;
      }
    });

    subscribeToChannel(broadcastChannelTypeAlerts, store.state.user!.id,
        (message) {
      switch (message.type) {
        case broadcastTypeNewAlert:
          store.dispatch(AddAlertAction(alert: Alert.fromJson(message.data)));
          setState(() {});
          break;
      }
    });
  }

  @override
  Widget body(BuildContext context) =>
      IndexedStack(index: _currentIndex, children: _fragments);

  @override
  bool get addBackButton => false;

  @override
  String get title => _currentIndex == 0
      ? 'Notifications'
      : _currentIndex == 1
          ? 'Hi, ${store.state.user!.firstName}'
          : 'Profile';

  @override
  FloatingActionButton? get fab => _currentIndex == 1
      ? FloatingActionButton(
          heroTag: "add_goal",
          child: const Icon(Icons.add),
          onPressed: () {
            simpleBottomSheet(
              title: 'New goal',
              height: 0,
              child: TextEditModal(
                placeholder: 'I wanna...',
                maxLength: 50,
                maxLines: 1,
                validate: (title) => title != null && title.isNotEmpty
                    ? null
                    : 'Title cannot be empty',
                onSave: (s) {
                  if (s != null && s.isNotEmpty) {
                    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
                    final newGoal = Goal(
                      id: const Uuid().v4(),
                      title: s,
                      year: store.state.date.year,
                      createdOn: DateTime.now(),
                      deletedOn: null,
                    );

                    setIsLoading(true);
                    ModuleService.createGoal(newGoal).then((goal) {
                      setIsLoading(false);
                      store.dispatch(CreateGoalAction(goal: goal));

                      showSnackBar(
                        'New goal created!',
                        action: SnackBarAction(
                          label: 'View',
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/goal', arguments: goal.id);
                          },
                        ),
                      );
                    });
                  }
                },
              ),
            );
          },
        )
      : null;

  @override
  BottomNavigationBar? get bottomNavigationBar => BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      );

  @override
  List<Widget> get actions => [];

  @override
  RefreshCallback get onRefresh => () async {
        Map<String, dynamic> user =
            await UserService().getProfile(store.state.user!.id);
        store.dispatch(SetUserAction(user: user['user']));
        store.dispatch(SetGoalsAction(goals: user['goals']));
        store.dispatch(SetFriendsAction(friends: user['friends']));
        store.dispatch(SetAlertsAction(alerts: user['alerts']));
      };

  void _processProfileAction(String name, {dynamic data}) {
    switch (name) {
      case setProfileImage:
        _openImagePicker();
        break;

      case editUserFirstName:
        _openNameEditor();
        break;

      case editUserEmail:
        _openEmailEditor();
        break;

      case goReports:
        Navigator.of(context).pushNamed('/reports');
        break;

      case editUserPassword:
        _openPasswordEditor();
        break;

      case validateEmail:
        _validateEmail();
        break;

      case logout:
        Security.logOut().then((_) {
          Navigator.of(context).popUntil((route) => false);
          Navigator.of(context).pushNamed('/login');
        });
        break;

      default:
        debugPrint('Unknown action: $name');
        break;
    }
  }

  void _processAlertsAction(String name, {dynamic data}) {
    switch (name) {
      case goFriends:
        Navigator.of(context).pushNamed('/friends');
        break;

      default:
        debugPrint('Unknown action: $name');
        break;
    }
  }

  void _openNameEditor() {
    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
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
          Store<ApplicationState> store = StoreProvider.of(context);
          User user = store.state.user!.deepCopy();
          user.firstName = s!;
          ModuleService.updateUser(user, store)
              .then((_) => setIsLoading(false));
        },
      ),
    );
  }

  void _openEmailEditor() {
    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
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
          Store<ApplicationState> store = StoreProvider.of(context);
          User user = store.state.user!.deepCopy();
          user.email = s!;
          ModuleService.updateUser(user, store)
              .then((_) => setIsLoading(false));
        },
      ),
    );
  }

  void _openPasswordEditor() {
    GlobalKey<FormState> passwordFormKey = GlobalKey();
    GlobalKey<TextEditState> oldPassKey = GlobalKey();
    GlobalKey<TextEditState> newPassKey = GlobalKey();
    GlobalKey<TextEditState> repeatPassKey = GlobalKey();

    bool hasPassword =
        store.state.user!.authProviders.contains(AuthProvider.email);

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
                validate: (s) => hasPassword && (s == null || s.isEmpty)
                    ? 'You must enter the current password.'
                    : null,
                enabled: hasPassword,
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
                    await ModuleService.changePassword(
                        oldPassword, newPassword);
                    if (!store.state.user!.authProviders
                        .contains(AuthProvider.email)) {
                      store.dispatch(
                          SetUserProvider(provider: AuthProvider.email));
                    }
                    navigator.pop();
                    setIsLoading(false);
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

  void _validateEmail() {
    setIsLoading(true);
    ModuleService.validateEmail().then((_) {
      setIsLoading(false);
      showSnackBar('Email validation sent!');
    });
  }

  Future<void> _openImagePicker() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? file = File(pickedFile.path);
      if (await file.exists()) {
        setIsLoading(true);
        await ModuleService.setProfileImage(file);
        setIsLoading(false);
      }
    }
  }
}
