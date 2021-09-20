import 'package:expense/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:collection';
import 'package:pie_chart/pie_chart.dart';

class ScreenArguments {
  final int month;
  final int year;
  LinkedHashMap<DateTime, List<Transaction>> transactions;

  ScreenArguments(this.transactions, this.month, this.year);
}

class DailyTransaction {
  final DateTime date;
  final Transaction trans;
  DailyTransaction(this.date, this.trans);
}

class ExpenseSummaryScreen extends StatelessWidget {
  ExpenseSummaryScreen({Key? key, required this.title}) : super(key: key);

  final String title;
  final double budget = 0;
  final Map<String, double> categoryChart = Map();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    var transactions = [];
    num sum = 0;

    args.transactions.entries.forEach((e) => {
          if ((args.month == 0 || e.key.month == args.month) &&
              e.key.year == args.year)
            e.value.forEach((element) {
              transactions.add(DailyTransaction(e.key, element));
            })
        });

    transactions.forEach((e) {
      categoryChart[e.trans.category] =
          (categoryChart[e.trans.category] ?? 0) + e.trans.amount;
      sum += e.trans.amount;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(
              top: 30.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Expense: $sum'),
                  Text('Budget: $budget'),
                ]),
          ),
          PieChart(dataMap: categoryChart),
          Container(
            child: new Flexible(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: null,
                      title: Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('${transactions[index].trans.category}'),
                            Text('${transactions[index].trans.vendor}'),
                            Text(
                                '${transactions[index].trans.amount.toString()}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// DataTable createDataTable(transactions) {
//   return DataTable(
//     headingRowHeight: 0,
//     dividerThickness: 0,
//     columns: <DataColumn>[
//       DataColumn(label: Text('')),
//       DataColumn(label: Text('')),
//       DataColumn(label: Text('')),
//       DataColumn(label: Text(''))
//     ],
//     rows: transactions
//         .map((t) => DataRow(
//               cells: <DataCell>[
//                 DataCell(Text(DateFormat.yMMMd().format(t.date))),
//                 DataCell(Text(t.trans.category)),
//                 DataCell(Text(t.trans.vendor)),
//                 DataCell(Text(t.trans.amount.toStringAsFixed(2))),
//               ],
//             ))
//         .toList()
//         .cast<DataRow>(),
//   );
// }