import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date, {String formatStr = 'dd/MM/yyyy'}) {
    return DateFormat(formatStr).format(date);
  }
  
  static String formatWithTime(DateTime date, {String formatStr = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(formatStr).format(date);
  }

  static String formatDateTime(DateTime date, {String formatStr = 'dd/MM/yyyy HH:mm:ss'}) {
    return DateFormat(formatStr).format(date);
  }
}
