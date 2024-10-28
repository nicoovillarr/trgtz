import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/core/base/index.dart';
import 'package:trgtz/core/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/profile/providers/index.dart';
import 'package:trgtz/screens/profile/widgets/index.dart';

class SingleProfileView extends StatefulWidget {
  final String userId;
  final String me;
  const SingleProfileView({
    super.key,
    required this.userId,
    required this.me,
  });

  @override
  State<SingleProfileView> createState() => _SingleProfileViewState();
}

class _SingleProfileViewState extends BaseScreen<SingleProfileView> {
  bool _loaded = false;
  bool _areFriends = false;
  bool _requestSent = false;
  bool _requestReceived = false;
  late ProfileModel model;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context
          .read<SingleProfileProvider>()
          .getProfile(widget.userId)
          .then((_) async {
        final profileProvider =
            Provider.of<SingleProfileProvider>(context, listen: false);
        model = profileProvider.profileModel!;
        _areFriends = model.friends
            .any((f) => f.otherUserId == widget.me && f.status == 'accepted');
        _requestSent = model.friends
            .any((f) => f.otherUserId == widget.me && f.status == 'pending');
        _requestReceived = model.friends
            .any((f) => f.otherUserId == widget.me && f.status == 'pending');
        _loaded = true;
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            color: Colors.white,
            child: ProfileBanner(
              user: model.user,
              friendsCount: model.friends.length,
              goalsCount: model.goals.length,
              itsMe: model.user.id == widget.me,
              padding: const EdgeInsets.all(16.0),
              onReport: _showUserReportDialog,
            ),
          ),
          if (!_areFriends)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: MButton(
                  onPressed: _friendRequestAction,
                  type: MButtonType.secondary,
                  outlined: true,
                  borderRadius: 16.0,
                  leading: _requestSent || _requestReceived
                      ? const Icon(Icons.check, size: 18.0)
                      : null,
                  child: _requestReceived
                      ? Text('Request Received')
                      : _requestSent
                          ? Text('Request Sent')
                          : Text('Send Friend Request'),
                ),
              ),
            ),
          ProfileGoalsList(
            goals: model.goals,
            canEnterGoal: _areFriends || widget.me == widget.userId,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            height: 140.0,
            child: ProfileBanner.placeholder(
              padding: const EdgeInsets.all(16.0),
            ),
          ),
          ProfileGoalsList.placeholder(),
        ],
      );
    }
  }

  void _showUserReportDialog() {
    simpleBottomSheet(
      height: MediaQuery.of(context).size.height * 0.95,
      builder: (context, _) => ReportDialog(
        categoriesAvailable: Report.forGoal(),
        entityType: 'user',
        entityId: model.user.id,
        showCommunityGuidelines: _showCommunityGuidelines,
      ),
    );
  }

  void _showCommunityGuidelines() {
    simpleBottomSheet(
      height: MediaQuery.of(context).size.height * 0.825,
      builder: (context, _) => const CommunityGuidelines(),
    );
  }

  void _friendRequestAction() {
    if (_areFriends || _requestSent && !_requestReceived) {
      return;
    }
    setIsLoading(true);

    if (_requestReceived) {
      context
          .read<SingleProfileProvider>()
          .acceptFriendRequest(model.user.id)
          .then((_) {
        setIsLoading(false);
        setState(() {
          _areFriends = true;
        });
      });
      return;
    } else {
      context
          .read<SingleProfileProvider>()
          .sendFriendRequest(model.user.id)
          .then((_) {
        setIsLoading(false);
        setState(() {
          _requestSent = true;
        });
      });
    }
  }
}
