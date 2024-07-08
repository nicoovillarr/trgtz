import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/home/fragments/index.dart';
import 'package:trgtz/screens/home/services/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

GlobalKey<HomeScreenState> homeScreenKey = GlobalKey();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends BaseScreen<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _fragments;

  @override
  void initState() {
    _fragments = [
      const DashboardFragment(),
      FriendsFragment(
        enimtAction: _processAction,
      ),
    ];
    super.initState();
  }

  @override
  Widget body(BuildContext context) =>
      IndexedStack(index: _currentIndex, children: _fragments);

  @override
  bool get addBackButton => false;

  @override
  String get title =>
      _currentIndex == 0 ? 'Hi, ${store.state.user!.firstName}' : 'Friends';

  @override
  FloatingActionButton? get fab => _currentIndex == 0
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
                    }).catchError((_) {
                      setIsLoading(false);
                      showMessage(
                        'Error',
                        'An error occurred while creating the goal.',
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Friends',
          ),
        ],
      );

  @override
  List<Widget> get actions => [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed('/profile'),
          icon: const Icon(
            Icons.settings,
          ),
        ),
        if (_currentIndex == 1) ..._buildFriendsActions(),
      ];

  List<Widget> _buildFriendsActions() => [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        CustomPopUpMenuButton(
          items: [
            MenuItem(
              title: 'Show QR code',
              onTap: () => _showQRCodeDialog(),
            ),
          ],
        ),
      ];

  void _processAction(String name) {
    switch (name) {
      case showQRCode:
        _showQRCodeDialog();
        break;

      case showFriendRequests:
        _showFriendRequests(
            context,
            store.state.friends!
                .where((element) =>
                    element.status == 'pending' &&
                    element.requester != store.state.user!.id)
                .toList());
        break;

      case showFriendOptions:
        simpleBottomSheetOptions(
          options: [
            BottomModalOption(
              title: 'Remove',
              onTap: () => debugPrint('Remove friend'),
            ),
          ],
        );
        break;

      default:
        debugPrint('Unknown action: $name');
        break;
    }
  }

  void _showQRCodeDialog() {
    Size size = MediaQuery.of(context).size;
    Store<AppState> store = StoreProvider.of<AppState>(context);
    simpleBottomSheet(
      child: SizedBox(
        height: size.height * 0.75,
        width: size.width,
        child: Column(
          children: [
            const Text('Share this code with your friends:'),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: size.width * 0.5,
                height: size.width * 0.5,
                child: const Placeholder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('#${store.state.user!.id}'),
                IconButton(
                  onPressed: () => Clipboard.setData(
                      ClipboardData(text: store.state.user!.id)),
                  icon: const Icon(
                    Icons.copy,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFriendRequests(BuildContext context, List<Friendship> requests) {
    simpleBottomSheet(
      title: 'Friend requests',
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              for (int i = 0; i < requests.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(requests[i].friendDetails.firstName),
                          Text(
                            timeago.format(
                              requests[i].createdOn,
                            ),
                            style: const TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _answerFriendRequest(
                        requests[i].requester,
                        true,
                      ),
                      icon: const Icon(Icons.check),
                    ),
                    IconButton(
                      onPressed: () => _answerFriendRequest(
                        requests[i].requester,
                        false,
                      ),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _answerFriendRequest(String requesterId, bool answer) async {
    setIsLoading(true);
    try {
      await ModuleService.answerFriendRequest(requesterId, answer);
    } catch (e) {
      showMessage('Error', e.toString());
    } finally {
      setIsLoading(false);
    }
  }
}
