import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/store/index.dart';

const String showQRCode = 'SHOW_QR_CODE';
const String showFriendRequests = 'SHOW_FRIEND_REQUESTS';
const String showFriendOptions = 'SHOW_FRIEND_OPTIONS';

class FriendsFragment extends BaseFragment {
  const FriendsFragment({
    super.key,
    required super.enimtAction,
  });

  @override
  State<FriendsFragment> createState() => _FriendsFragmentState();
}

class _FriendsFragmentState extends BaseFragmentState<FriendsFragment> {
  @override
  Widget build(BuildContext context) =>
      StoreConnector<AppState, List<Friendship>>(
        builder: (context, friends) => Stack(
          children: [
            if (friends.isEmpty) _buildNoFriendsMessage(),
            if (friends.isNotEmpty) _buildFriendsList(friends),
            _buildPendingRequestModal(
              context,
              friends
                  .where(
                    (f) => f.status == 'pending',
                  )
                  .toList(),
            ),
          ],
        ),
        converter: (store) => store.state.friends ?? [],
      );

  Widget _buildPendingRequestModal(
          BuildContext context, List<Friendship> prendingRequests) =>
      AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        bottom: prendingRequests.isNotEmpty ? 16 : -1000,
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
                    'You have ${prendingRequests.length} friend requests pending.',
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
                      onTap: () => widget.enimtAction(showFriendRequests),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () => widget.enimtAction(showQRCode),
              child: const Text('Share code'),
            ),
          ],
        ),
      );

  Widget _buildFriendsList(List<Friendship> friends) {
    List<Friendship> actualFriends = friends
        .where((f) => f.status == 'accepted' && f.deletedOn == null)
        .toList();
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actualFriends.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) => _buildFriendItem(
            actualFriends[index],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendItem(Friendship friend) => Material(
        elevation: 2,
        shadowColor: Colors.blueGrey,
        child: ListTile(
          title: Text(friend.friendDetails.firstName),
          subtitle: Text(friend.friendDetails.email),
          onLongPress: () =>
              widget.enimtAction(showFriendOptions, data: friend),
        ),
      );
}
