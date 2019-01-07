class SortHelper {

  static String getStringValueOfSort<T>(T sort) {
    String stringSort = sort.toString().split('.').last.toLowerCase();

    return stringSort;
  }
}
