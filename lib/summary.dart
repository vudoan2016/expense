import 'package:expense/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;

class ScreenArguments {
  final int month;
  final int year;
  final EventList<Transaction> markedDateMap;

  ScreenArguments(this.markedDateMap, this.month, this.year);
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
                DataCell(Text(t.title)),
                DataCell(Text(t.merchant)),
                DataCell(Text(t.amount.toStringAsFixed(2))),
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

    args.markedDateMap.events.entries.forEach(
      (e) => {
        if ((args.month == 0 || e.key.month == args.month) &&
            e.key.year == args.year)
          {transactions.addAll(e.value)}
      },
    );

    transactions.forEach((e) => sum += e.amount);

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
