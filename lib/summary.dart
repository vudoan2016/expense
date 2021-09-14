import 'package:expense/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:collection';

class ScreenArguments {
  final int month;
  final int year;
  LinkedHashMap<DateTime, List<Transaction>> transactions;

  ScreenArguments(this.transactions, this.month, this.year);
}

class TransactionInDay {
  final DateTime date;
  final Transaction trans;
  TransactionInDay(this.date, this.trans);
}

DataTable createDataTable(transactions) {
  return DataTable(
    headingRowHeight: 0,
    dividerThickness: 0,
    columns: <DataColumn>[
      DataColumn(label: Text('')),
      DataColumn(label: Text('')),
      DataColumn(label: Text('')),
      DataColumn(label: Text(''))
    ],
    rows: transactions
        .map((t) => DataRow(
              /*
              onSelectChanged: (newValue) {
                print('row 1 pressed ${t.index}');
              },
              */
              cells: <DataCell>[
                DataCell(Text(DateFormat.yMMMd().format(t.date))),
                DataCell(Text(t.trans.category)),
                DataCell(Text(t.trans.vendor)),
                DataCell(Text(t.trans.amount.toStringAsFixed(2))),
              ],
            ))
        .toList()
        .cast<DataRow>(),
  );
}

class ExpenseSummaryScreen extends StatelessWidget {
  ExpenseSummaryScreen({Key? key, required this.title}) : super(key: key);

  final String title;
  final double budget = 0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    var transactions = [];
    num sum = 0;

    args.transactions.entries.forEach((e) => {
          if ((args.month == 0 || e.key.month == args.month) &&
              e.key.year == args.year)
            e.value.forEach((element) {
              transactions.add(TransactionInDay(e.key, element));
            })
        });

    transactions.forEach((e) => sum += e.trans.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Expense: $sum'),
                  Text('Budget: $budget'),
                ]),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: createDataTable(transactions)),
          ],
        ),
      ),
    );
  }
}
