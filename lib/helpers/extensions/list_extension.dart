///List extension to extend List functionality
extension ListExtension on List<dynamic> {
  ///Get sorted list
  ///
  ///Example:
  ///```dart
  ///list.sorted(true) // create new list with descending order
  ///```
  List<dynamic> sorted([final bool isDesc = false]) {
    sort();
    return isDesc ? reversed.toList() : this;
  }

  ///Get sorted list
  ///
  ///Example:
  ///```dart
  ///list.sortedDesc() // create new list with descending order
  ///```
  List<dynamic> get sortedDesc => sorted(true);

  ///The sortBy method sorts the list of objects by the given key.
  ///
  ///Example:
  ///```dart
  ///list.sortBy("price") // create new list with soreted list according to price
  ///```
  List<dynamic> sortBy(final String key, [final bool isDesc = false]) {
    if (isEmpty || first is! Map<dynamic, dynamic> || !first.containsKey(key)) {
      return <dynamic>[];
    }

    sort((final dynamic a, final dynamic b) => a[key].compareTo(b[key]));

    return isDesc ? reversed.toList() : this;
  }

  ///The sortBy method sorts the list of objects by the given key.
  ///
  ///Example:
  ///```dart
  ///list.sortBy("price")
  ///
  ///This method has the same signature as the sortBy method,
  ///but will sort the collection in the opposite order
  ///```
  List<dynamic> sortByDesc(final String key) => sortBy(key, true);

  ///Returns random value from this list
  ///
  ///Example:
  ///```dart
  ///list.random // [1,2,3,4,5] -> 4
  ///```
  dynamic get random => (this..shuffle()).first;

  ///The chunk method breaks the list into multiple, smaller list of a given size
  ///
  ///Example:
  ///```dart
  ///list.chunk(2) // [1,2,3,4,5] -> [[1,2], [3,4], [5]]
  ///```
  List<dynamic> chunk(final int size) {
    final List<dynamic> chunks = <dynamic>[];

    if (size < 1) return <dynamic>[];

    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }

    return chunks;
  }

  ///The split method breaks the list into equal sized lists of a given size
  ///
  ///Example:
  ///```dart
  ///list.split(2) // [1,2,3,4,5] -> [[1,2,3], [4,5]]
  ///```
  List<dynamic> split(final int parts) {
    if (parts < 1) return <dynamic>[];

    final int size = (length / parts).round();

    return List<dynamic>.generate(
        parts,
        (final int i) => sublist(
            size * i, (i + 1) * size <= length ? (i + 1) * size : null));
  }

  ///Get minimum number
  dynamic get min => sorted().first;

  ///Get maximum number
  dynamic get max => sortedDesc.first;

  ///Get sum of numbers
  num get sum => cast<num>().reduce((final num a, final num b) => a + b);

  ///Get average of numbers
  num get avg => sum / cast<num>().length;

  ///Get median of numbers
  num get median {
    final num middle = length ~/ 2;
    if (length.isOdd) {
      return this[middle as int];
    } else {
      return (this[middle - 1 as int] + this[middle as int]) / 2.0;
    }
  }

  ///Get mode of numbers
  num get mode {
    num maxValue = 0.0;
    num maxCount = 0;

    for (num i = 0; i < length; ++i) {
      num count = 0;
      for (num j = 0; j < length; ++j) {
        if (this[j as int] == this[i as int]) ++count;
      }

      if (count > maxCount) {
        maxCount = count;
        maxValue = this[i as int];
      }
    }
    return maxValue;
  }
}

extension MyIterable<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? firstWhereOrNull(final bool Function(T element) test) {
    final Iterable<dynamic> list = where(test);
    return list.isEmpty ? null : list.first;
  }
}

extension ListExt on List<dynamic>? {
  bool isNullOrEmpty() {
    if (this != null) {
      return this!.isEmpty;
    }
    return true;
  }

  bool isNotNullOrEmpty() {
    return !isNullOrEmpty();
  }
}
