import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/friends/services/index.dart';

class FriendsListScreenModel {
  final List<Friendship> _friends;
  final List<Friendship> _pendingFriends;
  int _pendingFriendRequestsCount;

  FriendsListScreenModel({
    required List<Friendship> friends,
    required List<Friendship> pendingFriends,
    required int pendingFriendRequestsCount,
  })  : _friends = friends,
        _pendingFriends = pendingFriends,
        _pendingFriendRequestsCount = pendingFriendRequestsCount;

  List<Friendship> get friends => _friends;

  List<Friendship> get pendingFriends => _pendingFriends;

  int get pendingFriendRequestsCount => _pendingFriendRequestsCount;

  set pendingFriendRequestsCount(int value) {
    _pendingFriendRequestsCount = value;
  }
}

class FriendsListScreenProvider extends ChangeNotifier {
  final ModuleService _moduleService = ModuleService();
  FriendsListScreenModel? _model;

  FriendsListScreenModel? get model => _model;

  Future populate(String userId, bool itsMe) async {
    List<Friendship> obj = await _moduleService.getFriends(userId);
    List<Friendship> pendingFriends = [];
    if (itsMe) {
      pendingFriends = await _moduleService.getPendingFriendRequests(userId);
    }
    _model = FriendsListScreenModel(
      friends: obj,
      pendingFriends: pendingFriends,
      pendingFriendRequestsCount: pendingFriends.length,
    );
    notifyListeners();
  }

  Future<List<Friendship>> fetchPendingFriendRequests(String userId) async {
    List<Friendship> obj =
        await _moduleService.getPendingFriendRequests(userId);
    _model = FriendsListScreenModel(
      friends: _model?.friends ?? [],
      pendingFriends: obj,
      pendingFriendRequestsCount: obj.length,
    );
    notifyListeners();

    return obj;
  }

  Future fetchFriends(String userId) async {
    List<Friendship> obj = await _moduleService.getFriends(userId);
    _model = FriendsListScreenModel(
      friends: obj,
      pendingFriends: _model?.pendingFriends ?? [],
      pendingFriendRequestsCount: _model?.pendingFriendRequestsCount ?? 0,
    );
    notifyListeners();
  }

  void addPendingFriendRequest() {
    _model?.pendingFriendRequestsCount++;
    notifyListeners();
  }

  void removePendingFriendRequest(Friendship requester) {
    _model?.pendingFriends.remove(requester);
    _model?.pendingFriendRequestsCount--;
    notifyListeners();
  }

  void deleteFriend(String friendId) {
    _model?.friends.removeWhere((element) => element.otherUserId == friendId);
    notifyListeners();
  }

  Future<User> getProfile(String userId) async =>
      await _moduleService.getProfile(userId);
}
