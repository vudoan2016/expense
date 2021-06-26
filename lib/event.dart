import 'package:flutter/foundation.dart';

class Event {
  final String vendor;
  final double amount;
  Event({@required this.vendor, @required this.amount});

  String toString() => '$this.vendor, $this.amount';
}
