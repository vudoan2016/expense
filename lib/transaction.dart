import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class Transaction extends Event {
  final String merchant;
  final double amount;

  Transaction(DateTime date, String title, Widget icon, Widget dot,
      String merchant, double amount)
      : merchant = merchant,
        amount = amount,
        super(date: date, title: title, icon: icon, dot: dot);
}
