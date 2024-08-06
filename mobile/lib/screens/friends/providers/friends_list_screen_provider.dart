import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/friends/services/index.dart';

class FriendsListScreenModel {
  final List<Friendship> _friends;
  final List<Friendship> _pendingFriends;

  FriendsListScreenModel({
    required List<Friendship> friends,
    required List<Friendship> pendingFriends,
  })  : _friends = friends,
        _pendingFriends = pendingFriends;

  List<Friendship> get friends => _friends;

  List<Friendship> get pendingFriends => _pendingFriends;
}

class FriendsListScreenProvider extends ChangeNotifier {
  final ModuleService _moduleService = ModuleService();
  FriendsListScreenModel? _model;

  FriendsListScreenModel? get model => _model;

  Future populate(String userId, bool itsMe) async {
    List<Friendship> obj = await _moduleService.getFriends(userId);
    List<Friendship> pendingFriends = [];
    if (itsMe)
      pendingFriends = await _moduleService.getPendingFriendRequests(userId);
    _model = FriendsListScreenModel(
      friends: obj,
      pendingFriends: pendingFriends,
    );
    notifyListeners();
  }
}
