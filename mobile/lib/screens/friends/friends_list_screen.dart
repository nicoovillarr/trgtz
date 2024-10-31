import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/friends/providers/index.dart';
import 'package:trgtz/screens/friends/services/index.dart';
import 'package:trgtz/screens/profile/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:trgtz/store/index.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends BaseScreen<FriendsListScreen> {
  late String userId;

  bool get itsMe => userId == user!.id;

  @override
  Future afterFirstBuild(BuildContext context) async {
    userId = ModalRoute.of(context)?.settings.arguments as String? ?? user!.id;
    context.read<FriendsListScreenProvider>().populate(userId, itsMe);
  }

  @override
  void initSubscriptions() {
    if (!itsMe) {
      return;
    }

    subscribeToChannel(
      broadcastChannelTypeFriends,
      store.state.user!.id,
      (message) {
        final viewModel = context.read<FriendsListScreenProvider>();
        switch (message.type) {
          case broadcastTypeFriendRequest:
            viewModel.addPendingFriendRequest();
            setState(() {});
            break;

          case broadcastTypeFriendAccepted:
            viewModel.fetchFriends(userId).then((_) => setState(() {}));
            break;

          case broadcastTypeFriendDeleted:
            viewModel.deleteFriend(message.data);
            setState(() {});
            break;
        }
      },
    );
  }

  @override
  Widget body(BuildContext context) =>
      Selector<FriendsListScreenProvider, List<Friendship>?>(
        selector: (context, provider) => provider.model?.friends,
        builder: (context, friends, child) => friends == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  if (friends.isEmpty) _buildNoFriendsMessage(),
                  if (friends.isNotEmpty)
                    _buildFriendsList(friends
                        .where((element) =>
                            element.status == 'accepted' &&
                            element.deletedOn == null)
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
            onTap: () => simpleBottomSheet(
              child: SingleProfileView(
                userId: friends[index].friendDetails.id,
                me: store.state.user!.id,
              ),
              height: MediaQuery.of(context).size.height * 0.75,
            ),
            title: Text(friends[index].friendDetails.firstName),
            subtitle:
                Text('Since ${timeago.format(friends[index].updatedOn!)}'),
            leading: ProfileImage(user: friends[index].friendDetails),
            trailing: itsMe
                ? IconButton(
                    key: iconKey,
                    icon: const Icon(Icons.more_vert),
                    onPressed: () =>
                        _showContextMenu(context, iconKey, friends[index]),
                  )
                : null,
          );
        },
      );

  Widget _buildPendingRequestModal(BuildContext context) =>
      Selector<FriendsListScreenProvider, int>(
        selector: (context, provider) =>
            provider.model?.pendingFriendRequestsCount ?? 0,
        builder: (context, pendingFriendRequests, child) => AnimatedPositioned(
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
  List<Widget> get actions => itsMe
      ? [
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
        ]
      : [];

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
    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
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
    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
    simpleBottomSheet(
      height: size.height * 0.6,
      child: Column(
        children: [
          const Text('Share this code with your friends:'),
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              data: '${dotenv.env["WEB"]}/friend/${store.state.user!.id}',
              version: QrVersions.auto,
              size: size.width * 0.5,
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
    );
  }

  void _showFriendRequests(BuildContext context) {
    context
        .read<FriendsListScreenProvider>()
        .fetchPendingFriendRequests(userId)
        .then((requests) {
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

  void _answerFriendRequest(String requesterId, bool answer) {
    setIsLoading(true);
    ModuleService.answerFriendRequest(requesterId, answer).then((_) {
      context.read<FriendsListScreenProvider>().substractPendingFriendRequest();
      setIsLoading(false);
    });
  }
}
