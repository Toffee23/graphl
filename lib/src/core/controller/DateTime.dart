
import 'package:intl/intl.dart';

String formatTime(DateTime dateTime) {
  // Format day of week
  String dayOfWeek = DateFormat('EEEE').format(dateTime);

  // Format day with suffix
  String dayOfMonth = DateFormat('d').format(dateTime);
  String daySuffix = _getDaySuffix(int.parse(dayOfMonth));
  String formattedDay = '$dayOfMonth$daySuffix';

  // Format month
  String month = DateFormat('MMMM').format(dateTime);

  // Format year
  String year = DateFormat('y').format(dateTime);

  // Format hour in 12-hour format with 'am' or 'pm'
  String hour = DateFormat('h').format(dateTime);
  String period = DateFormat('a').format(dateTime);

  // Construct the formatted string
  return '$dayOfWeek, $formattedDay $month $year, $hour$period';
}

String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}