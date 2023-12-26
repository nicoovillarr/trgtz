import 'package:intl/intl.dart';
import 'package:mobile/models/goal.dart';

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

  static List<Goal> getInProgressGoals(List<Goal> source) => source
      .where((element) =>
          element.inProgressOn != null && element.completedOn == null)
      .toList();

  static List<Goal> getToDoGoals(List<Goal> source) =>
      source.where((element) => element.inProgressOn == null).toList();
}
