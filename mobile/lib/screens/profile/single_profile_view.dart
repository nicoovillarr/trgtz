import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/profile/providers/index.dart';
import 'package:trgtz/screens/profile/widgets/index.dart';

class SingleProfileView extends StatefulWidget {
  final User user;
  final String me;
  const SingleProfileView({
    super.key,
    required this.user,
    required this.me,
  });

  @override
  State<SingleProfileView> createState() => _SingleProfileViewState();
}

class _SingleProfileViewState extends State<SingleProfileView> {
  bool _loaded = false;
  late ProfileModel model;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context
          .read<SingleProfileProvider>()
          .getProfile(widget.user.id)
          .then((_) async {
        final profileProvider =
            Provider.of<SingleProfileProvider>(context, listen: false);
        model = profileProvider.profileModel!;
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
            height: 140.0,
            color: Colors.white,
            child: ProfileBanner(
              user: widget.user,
              friendsCount: model.friends.length,
              goalsCount: model.goals.length,
              itsMe: widget.user.id == widget.me,
              padding: const EdgeInsets.all(16.0),
            ),
          ),
          ProfileGoalsList(goals: model.goals),
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
}
