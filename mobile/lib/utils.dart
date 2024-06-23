import 'package:intl/intl.dart';
import 'package:trgtz/models/goal.dart';
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

  static List<Goal> sortGoals(List<Goal> source) {
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
    return goals;
  }

  static String sanitize(String input) =>
      input.trim().replaceAll(RegExp(r'\s+'), ' ');

  static Future<bool> hasToken() async => await LocalStorage.getToken() != null;
}
