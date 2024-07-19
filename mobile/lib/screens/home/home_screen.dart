import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/home/fragments/index.dart';
import 'package:trgtz/screens/home/services/index.dart';
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

  @override
  void initState() {
    _fragments = [
      NotificationsFragment(enimtAction: _processProfileAction),
      DashboardFragment(enimtAction: _processProfileAction),
      ProfileFragment(enimtAction: _processProfileAction),
    ];

    super.initState();
  }

  @override
  Future afterFirstBuild(BuildContext context) async {
    subscribeToChannel('USER', store.state.user!.id, (message) {
      switch (message.type) {
        case broadcastTypeUserUpdate:
          store.dispatch(UpdateUserFields(fields: message.data));
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
              child: TextEditModal(
                placeholder: 'I wanna...',
                maxLength: 50,
                maxLines: 1,
                validate: (title) => title != null && title.isNotEmpty
                    ? null
                    : 'Title cannot be empty',
                onSave: (s) {
                  if (s != null && s.isNotEmpty) {
                    Store<AppState> store = StoreProvider.of<AppState>(context);
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
            label: 'Notifications',
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

  void _processProfileAction(String name, {dynamic data}) {
    switch (name) {
      case editUserFirstName:
        _openNameEditor();
        break;

      case editUserEmail:
        _openEmailEditor();
        break;

      case editUserPassword:
        _openPasswordEditor();
        break;

      default:
        debugPrint('Unknown action: $name');
        break;
    }
  }

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
          User user = store.state.user!.deepCopy();
          user.firstName = s!;
          ModuleService.updateUser(user, store)
              .then((_) => setIsLoading(false));
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
                    await ModuleService.changePassword(
                        oldPassword, newPassword, store);
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
}
