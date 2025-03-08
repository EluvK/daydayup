int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final kFirstDay = DateTime(1970, 1, 1);
final kLastDay = DateTime(2077, 12, 31);

/// Checks if two DateTime objects are the same day.
/// Returns `false` if either of them is null.
bool isSameDate(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime keepOnlyDay(DateTime dateTime) {
  return dateTime.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => keepOnlyDay(first).add(Duration(days: index)),
  );
}

DateTime utc2LocalDay(DateTime dateTime) {
  return keepOnlyDay(dateTime.toLocal());
}

const String userModifiedIcon = '🛠️';

// ignore: constant_identifier_names
const String VERSION = String.fromEnvironment('APP_VERSION', defaultValue: 'debug');

bool isDebug() {
  return VERSION == 'debug';
}

// ignore: constant_identifier_names
const String APP_BUILD_NUMBER = String.fromEnvironment('APP_BUILD_NUMBER', defaultValue: '0');
