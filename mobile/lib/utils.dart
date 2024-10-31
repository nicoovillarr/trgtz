import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trgtz/app.dart';
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
      case 'goal_reaction':
        return '${sentBy.firstName} reacted to a goal';
      case 'goal_comment':
        return '${sentBy.firstName} commented on a goal';
      case 'report_created':
        return 'Your report has been created';
      case 'report_resolved':
        return 'Your report has been resolved';
      case 'report_rejected':
        return 'Your report has been rejected';
      default:
        return message;
    }
  }

  static final Set<String> _loadedFonts = {};
  static Future preloadFonts(List<String> fontFamilies) async {
    if (fontFamilies.isEmpty) {
      return;
    }

    final fontsToLoad =
        fontFamilies.where((font) => !_loadedFonts.contains(font)).toList();

    if (fontsToLoad.isEmpty) {
      return;
    }

    final fontsReady = _systemFontsStream(fontsToLoad: fontsToLoad.length).last;
    GoogleFonts.asMap().forEach((key, value) {
      if (fontsToLoad.any((element) => element == key)) {
        value();
        _loadedFonts.add(key);
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

  static String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  static String formatDateTime(DateTime createdOn) =>
      DateFormat("MM-dd-yyyy HH:mm").format(createdOn);

  static String formatDate(DateTime createdOn) =>
      DateFormat("MM-dd-yyyy").format(createdOn);

  static void simpleBottomSheet({
    BuildContext? context,
    Widget? child,
    Widget Function(BuildContext, Widget?)? builder,
    String? title,
    double height = 350,
    Color backgroundColor = const Color(0xFFFFFFFF),
  }) {
    assert(context != null || navigatorKey.currentContext != null,
        'context should be provided');

    assert(child != null || builder != null,
        'child or builder should be provided');

    builder ??= (context, child) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(title),
                ),
              child!,
            ],
          ),
        );

    context ??= navigatorKey.currentContext!;

    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isScrollControlled: true,
      showDragHandle: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      useRootNavigator: false,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxHeight = (screenHeight * 0.875) - keyboardHeight;
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          height: height > 0 ? min(height, maxHeight) : null,
          color: backgroundColor,
          width: MediaQuery.of(context).size.width,
          child: builder!(context, child),
        );
      },
    );
  }
}
