int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

class Transaction {
  final String category;
  final String vendor;
  final double amount;

  const Transaction(this.category, this.vendor, this.amount);

  @override
  String toString() => category + vendor + amount.toString();
}
