import 'package:intl/intl.dart';

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
}
