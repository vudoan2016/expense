import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import 'package:expense/new_transaction.dart';
import 'package:expense/transaction.dart';
import 'package:expense/summary.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ValueNotifier<List<Transaction>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  late final DateTime today;
  late final DateTime firstTransaction;
  late final DateTime lastTransaction;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final allTransactions = LinkedHashMap<DateTime, List<Transaction>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void initState() {
    today = DateTime.now();
    firstTransaction = DateTime(today.year, today.month - 3, today.day);
    lastTransaction = DateTime(today.year, today.month + 3, today.day);
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Transaction> _getEventsForDay(DateTime day) {
    // Implementation example
    return allTransactions[day] ?? [];
  }

  List<Transaction> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  Future<void> _processTransactionRequest(
      DateTime date, Transaction old) async {
    final transaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NewTransactionScreen(title: DateFormat.yMMMd().format(date)),
        settings: RouteSettings(
          arguments: old,
        ),
      ),
    );
    if (transaction != null) {
      final beginningOfNextYear = DateTime(date.year + 1, 1, 1);
      DateTime nextDate = date;
      setState(() {
        if (transaction.isEmpty()) {
          // delete
          allTransactions[date]?.remove(old);
        } else {
          while (nextDate.isBefore(beginningOfNextYear)) {
            final transactionsOfDay = allTransactions[nextDate];
            if (transactionsOfDay == null) {
              allTransactions[nextDate] = [transaction];
            } else {
              transactionsOfDay.add(transaction);
            }
            _selectedEvents.value = _getEventsForDay(nextDate);
            if (transaction.frequency == 'Monthly') {
              nextDate =
                  DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
            } else if (transaction.frequency == 'Semi annually') {
              nextDate =
                  DateTime(nextDate.year, nextDate.month + 6, nextDate.day);
            } else {
              break;
            }
          }
        }
      });
    }
  }

  void _onDaySelectedCb(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onDayLongPressedCb(DateTime selectedDay, DateTime focusedDay) {
    _processTransactionRequest(selectedDay, Transaction.empty());
  }

  void _onRangeSelectedCb(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  // Display the calendar header
  Widget _customHeader() {
    return Container(
      margin: EdgeInsets.only(
        top: 30.0,
        bottom: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            // when click bring up monthly summary
            child: Text(
              DateFormat.MMM().format(_focusedDay),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue))),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseSummaryScreen(
                      title: DateFormat.yMMM().format(_focusedDay)),
                  settings: RouteSettings(
                    arguments: new ScreenArguments(
                        allTransactions, _focusedDay.month, _focusedDay.year),
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            // when click bring up yearly summary
            child: Text(
              DateFormat.y().format(_focusedDay),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue))),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseSummaryScreen(
                      title: DateFormat.y().format(_focusedDay)),
                  settings: RouteSettings(
                    arguments: new ScreenArguments(
                      allTransactions,
                      0,
                      _focusedDay.year,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          _customHeader(),
          TableCalendar<Transaction>(
            firstDay: firstTransaction,
            lastDay: lastTransaction,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelectedCb,
            onRangeSelected: _onRangeSelectedCb,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onDayLongPressed: _onDayLongPressedCb,
            headerVisible: false,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Transaction>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
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
                        onTap: () => _processTransactionRequest(
                            _selectedDay!, value[index]),
                        title: Container(
                            child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                              Text('${value[index].category}'),
                              Text('${value[index].vendor}'),
                              Text('${value[index].amount.toString()}'),
                            ])),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
