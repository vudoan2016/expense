import 'package:expense/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Map<DateTime, List<Event>> selectedDays;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTime firstDayOnPage;
  Map<DateTime, double> monthlyExpenses = new Map();

  TextEditingController _vendorController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    selectedDays = {};
    super.initState();
  }

  List<Event> _getEventsfromDay(DateTime date) {
    return selectedDays[date] ?? [];
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Calendar"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(1990),
            lastDay: DateTime(2050),
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            onPageChanged: (focusDay) {
              firstDayOnPage = focusDay;
              Text(
                  'Expense: $firstDayOnPage, ${monthlyExpenses[firstDayOnPage] ?? 0}');
            },
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,

            // Day selected
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },

            eventLoader: _getEventsfromDay,

            // Style
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Add Event"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _vendorController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Vendor',
                    ),
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  double amount = double.parse(_amountController.text);
                  if (_vendorController.text.isNotEmpty) {
                    if (selectedDays[selectedDay] != null) {
                      selectedDays[selectedDay].add(
                        Event(vendor: _vendorController.text, amount: amount),
                      );
                    } else {
                      selectedDays[selectedDay] = [
                        Event(vendor: _vendorController.text, amount: amount)
                      ];
                    }
                  }
                  Navigator.pop(context);
                  _vendorController.clear();
                  _amountController.clear();
                  setState(() {
                    print(firstDayOnPage);
                    if (monthlyExpenses[firstDayOnPage] != null) {
                      monthlyExpenses[firstDayOnPage] += amount;
                    } else {
                      monthlyExpenses[firstDayOnPage] = amount;
                    }
                  });
                  return;
                },
              ),
            ],
          ),
        ),
        label: Text("Add Event"),
        icon: Icon(Icons.add),
      ),
    );
  }
}
