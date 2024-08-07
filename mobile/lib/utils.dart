import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trgtz/models/goal.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/store/local_storage.dart';

class Utils {
  static String dateToFullString(DateTime date) {
    int dayNum = date.day;
    String daySuffix;
    if (dayNum >= 11 && dayNum <= 13) {
      daySuffix = 'th';
    } else {
      switch (dayNum % 10) {
        case 1:
          daySuffix = 'st';
          break;
        case 2:
          daySuffix = 'nd';
          break;
        case 3:
          daySuffix = 'rd';
          break;
        default:
          daySuffix = 'th';
          break;
      }
    }

    return "${DateFormat("MMMM").format(date)} ${DateFormat("d").format(date)}$daySuffix, ${date.year}";
  }

  static List<Goal> getCompletedGoals(List<Goal> source) =>
      source.where((element) => element.completedOn != null).toList();

  static List<Goal> getToDoGoals(List<Goal> source) =>
      source.where((element) => element.completedOn == null).toList();

  static List<Goal> sortGoals(List<Goal> source, {bool ascending = false}) {
    List<Goal> goals = source.toList();
    goals.sort((a, b) {
      if (a.completedOn == null && b.completedOn != null) {
        return -1;
      } else if (a.completedOn != null && b.completedOn == null) {
        return 1;
      } else if (a.completedOn == null && b.completedOn == null) {
        return b.createdOn.compareTo(a.createdOn);
      } else {
        return b.completedOn!.compareTo(a.completedOn!);
      }
    });
    return ascending ? goals.reversed.toList() : goals;
  }

  static String sanitize(String input) =>
      input.trim().replaceAll(RegExp(r'\s+'), ' ');

  static Future<bool> hasToken() async => await LocalStorage.getToken() != null;

  static bool validateEmail(String input) => input.contains('@');

  static String getAlertMessage(User sentBy, String message) {
    switch (message) {
      case 'friend_requested':
        return '${sentBy.firstName} wants to be your friend';
      case 'friend_accepted':
        return '${sentBy.firstName} and you are now friends';
      case 'goal_created':
        return '${sentBy.firstName} reated a new goal';
      case 'goal_completed':
        return '${sentBy.firstName} completed a goal';
      case 'milestone_completed':
        return '${sentBy.firstName} completed a milestone';
      default:
        return message;
    }
  }

  static Future preloadFonts(List<String> fontFamilies) async {
    final fontsReady =
        _systemFontsStream(fontsToLoad: fontFamilies.length).last;
    GoogleFonts.asMap().forEach((key, value) {
      if (fontFamilies.any((element) => element == key)) {
        value();
      }
    });

    await fontsReady;
  }

  static Stream<int> _systemFontsStream({int? fontsToLoad}) {
    late StreamController<int> controller;
    var loadedFonts = 0;

    void onSystemFontsLoaded() {
      loadedFonts++;
      controller.add(loadedFonts);
      if (loadedFonts == fontsToLoad) {
        controller.close();
      }
    }

    void addListener() {
      PaintingBinding.instance.systemFonts.addListener(onSystemFontsLoaded);
    }

    void removeListener() {
      PaintingBinding.instance.systemFonts.removeListener(onSystemFontsLoaded);
    }

    controller = StreamController<int>(
      onListen: addListener,
      onPause: removeListener,
      onResume: addListener,
      onCancel: removeListener,
    );

    return controller.stream;
  }
}
