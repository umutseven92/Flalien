import 'package:flalien/reddit/timeSort.dart';

class SortHelper {
  static String getStringValueOfSort<T>(T sort) {
    String stringSort = sort.toString().split('.').last.toLowerCase();

    return stringSort;
  }

  static String getFriendlyStringValueOfSort<T>(T sort) {
    String stringSort = sort.toString().split('.').last;

    return stringSort;
  }

  static String getFriendlyStringValueOfTimeSort(TimeSort sort) {
    switch (sort) {
      case TimeSort.All:
        return 'All time';
      case TimeSort.Day:
        return 'Past 24 hours';
      case TimeSort.Hour:
        return 'Past hour';
      case TimeSort.Week:
        return 'Past week';
      case TimeSort.Month:
        return 'Past month';
      case TimeSort.Year:
        return 'Past year';
    }
  }
}
