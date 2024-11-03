import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/services/index.dart';

class ProfileNotificationsModel {
  final String key;
  final String displayText;
  final bool isEnabled;

  ProfileNotificationsModel({
    required this.key,
    required this.displayText,
    required this.isEnabled,
  });

  ProfileNotificationsModel copyWith({
    String? key,
    String? displayText,
    bool? isEnabled,
  }) {
    return ProfileNotificationsModel(
      key: key ?? this.key,
      displayText: displayText ?? this.displayText,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class ProfileNotificationsProvider extends ChangeNotifier {
  final AlertService _alertService = AlertService();
  final UserService _userService = UserService();

  List<ProfileNotificationsModel> _notifications = [];

  List<ProfileNotificationsModel> get notifications => _notifications;

  Future<void> populate() async {
    final alertTypes = await _alertService.getAlertTypes();
    final userSubscribedTypes = await _userService.getUserSubscribedTypes();

    _notifications = alertTypes.entries
        .map((e) => ProfileNotificationsModel(
              key: e.key,
              displayText: e.value,
              isEnabled: userSubscribedTypes.contains(e.key),
            ))
        .toList();
  }

  Future toggle(String key, bool value) async {
    final index = _notifications.indexWhere((element) => element.key == key);
    if (index != -1) {
      if (value) {
        await _userService.subscribeToAlertType(key);
      } else {
        await _userService.unsubscribeToAlertType(key);
      }
    }
  }

  void processMessage(WebSocketMessage message) {
    switch (message.type) {
      case broadcastTypeUserAlertTypeSubscribed:
        final index =
            _notifications.indexWhere((element) => element.key == message.data);
        if (index != -1) {
          _notifications = _notifications.map((e) {
            if (e.key == message.data) {
              return e.copyWith(isEnabled: true);
            }
            return e;
          }).toList();
          notifyListeners();
        }
        break;

      case broadcastTypeUserAlertTypeUnsubscribed:
        final index =
            _notifications.indexWhere((element) => element.key == message.data);
        if (index != -1) {
          _notifications = _notifications.map((e) {
            if (e.key == message.data) {
              return e.copyWith(isEnabled: false);
            }
            return e;
          }).toList();
          notifyListeners();
        }
        break;
    }
  }
}
