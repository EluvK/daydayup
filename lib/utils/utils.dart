int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final kFirstDay = DateTime(2020, 1, 1);
final kLastDay = DateTime(2077, 12, 31);
