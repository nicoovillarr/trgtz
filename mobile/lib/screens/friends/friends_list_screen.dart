import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/friends/services/index.dart';

import 'package:trgtz/store/index.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends BaseScreen<FriendsListScreen> {
  @override
  Future afterFirstBuild(BuildContext context) async {
    _refresh();
  }

  @override
  void initSubscriptions() {
    subscribeToChannel(
      broadcastChannelTypeFriends,
      store.state.user!.id,
      (message) {
        switch (message.type) {
          case broadcastTypeFriendRequest:
            store.dispatch(const AddPendingFriendRequestAction());
            setState(() {});
            break;

          case broadcastTypeFriendAccepted:
            if (store.state.friends?.isEmpty ?? true) {
              _refresh();
            }
            break;

          case broadcastTypeFriendDeleted:
            store.dispatch(DeleteFriend(friendId: message.data));
            setState(() {});
            break;
        }
      },
    );
  }

  @override
  Widget body(BuildContext context) =>
      StoreConnector<AppState, List<Friendship>>(
        converter: (store) => store.state.friends ?? [],
        builder: (context, friends) => Stack(
          children: [
            if (friends.isEmpty) _buildNoFriendsMessage(),
            if (friends.isNotEmpty)
              _buildFriendsList(friends
                  .where((element) =>
                      element.status == 'accepted' && element.deletedOn == null)
                  .toList()),
            _buildPendingRequestModal(
              context,
            ),
          ],
        ),
      );

  Widget _buildNoFriendsMessage() => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'You don\'t have any friends, yet. Tap the button below to share your code.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Material(
              borderRadius: BorderRadius.circular(4.0),
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showQRCodeDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: const Text(
                    'Share code',
                    style: TextStyle(
                      color: textButtonColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFriendsList(List<Friendship> friends) => ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final GlobalKey iconKey = GlobalKey();
          return ListTile(
            title: Text(friends[index].friendDetails.firstName),
            subtitle:
                Text('Since ${timeago.format(friends[index].updatedOn!)}'),
            leading: ProfileImage(user: friends[index].friendDetails),
            trailing: IconButton(
              key: iconKey,
              icon: const Icon(Icons.more_vert),
              onPressed: () =>
                  _showContextMenu(context, iconKey, friends[index]),
            ),
          );
        },
      );

  Widget _buildPendingRequestModal(BuildContext context) =>
      StoreConnector<AppState, int>(
        converter: (store) => store.state.pendingFriendRequests ?? 0,
        builder: (context, pendingFriendRequests) => AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          bottom: pendingFriendRequests > 0 ? 16 : -1000,
          left: 16,
          right: 16,
          child: Material(
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).shadowColor.withOpacity(0.5),
                ),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'You have $pendingFriendRequests friend requests pending.',
                    ),
                  ),
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showFriendRequests(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Check',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

  @override
  String? get title => 'Friends';

  @override
  List<Widget> get actions => [
        IconButton(
          icon: const Icon(Icons.qr_code),
          tooltip: 'Share code',
          onPressed: () => _showQRCodeDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: _showSearchDialog,
        ),
      ];

  void _showContextMenu(
      BuildContext context, GlobalKey iconKey, Friendship friend) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button =
        iconKey.currentContext?.findRenderObject() as RenderBox;

    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonPosition,
        buttonPosition.translate(buttonSize.width, buttonSize.height),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: const [
        PopupMenuItem(
          value: 'Delete',
          child: Text('Delete'),
        ),
      ],
    ).then((value) {
      switch (value) {
        case 'Delete':
          _deleteFriend(friend);
          break;
      }
    });
  }

  void _deleteFriend(Friendship friend) async {
    setIsLoading(true);
    Store<AppState> store = StoreProvider.of<AppState>(context);
    await ModuleService.deleteFriend(store.state.user!.id, friend);
    setIsLoading(false);
  }

  void _showSearchDialog() {
    simpleBottomSheet(
      title: 'Add a friend',
      child: TextEditModal(
        placeholder: 'Search by code',
        buttonText: 'Send friend request',
        onSave: (code) async {
          if (code != null && code.isNotEmpty) {
            setIsLoading(true);
            await ModuleService.addFriend(code);
            setIsLoading(false);
          }
        },
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context) {
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

  void _showFriendRequests(BuildContext context) {
    ModuleService.getPendingFriendRequests().then((requests) {
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
    });
  }

  void _answerFriendRequest(String requesterId, bool answer) async {
    setIsLoading(true);
    await ModuleService.answerFriendRequest(requesterId, answer);
    setIsLoading(false);
  }

  Future _refresh() async {
    setIsLoading(true);
    await Future.wait([
      ModuleService.getFriends(),
      ModuleService.getPendingFriendRequests(),
    ]).then((value) {
      StoreProvider.of<AppState>(context).dispatch(
        SetFriendsAction(friends: value[0]),
      );
      store.dispatch(
        SetPendingFriendRequestsAction(count: value[1].length),
      );
    });
    setIsLoading(false);
  }
}
