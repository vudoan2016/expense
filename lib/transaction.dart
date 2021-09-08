import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class Transaction extends Event {
  final String merchant;
  final double amount;
  final String receiptImgPath;

  Transaction(DateTime date, String title, Widget icon, Widget dot,
      String merchant, double amount, String receiptImgPath)
      : merchant = merchant,
        amount = amount,
        receiptImgPath = receiptImgPath,
        super(date: date, title: title, icon: icon, dot: dot);
}
