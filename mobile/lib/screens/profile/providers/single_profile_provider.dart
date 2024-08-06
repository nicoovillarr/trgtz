import 'package:flutter/material.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/profile/services/index.dart';

class ProfileModel {
  final User user;
  final List<Friendship> friends;
  final List<Goal> goals;

  ProfileModel({
    required this.user,
    required this.friends,
    required this.goals,
  });
}

class SingleProfileProvider extends ChangeNotifier {
  final ModuleService _profileRepository = ModuleService();
  ProfileModel? _profileModel;

  ProfileModel? get profileModel => _profileModel;

  Future<void> getProfile(String userId) async {
    Map<String, dynamic> obj = await _profileRepository.getProfile(userId);
    _profileModel = ProfileModel(
      user: obj['user'],
      friends: obj['friends'],
      goals: obj['goals'],
    );
    notifyListeners();
  }
}
