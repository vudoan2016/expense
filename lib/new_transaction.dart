import 'package:flutter/material.dart';
import 'package:calendar/transaction.dart';

Widget _eventIcon = new Container(
  decoration: new BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(1000)),
      border: Border.all(color: Colors.blue, width: 2.0)),
  child: new Icon(
    Icons.person,
    color: Colors.amber,
  ),
);

class NewTransactionScreen extends StatefulWidget {
  NewTransactionScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NewTransactionScreenState createState() => new _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final double budget = 0;
  String _category = '', _merchant = '';

  @override
  Widget build(BuildContext context) {
    final date = ModalRoute.of(context)!.settings.arguments as DateTime;
    TextEditingController _amtController = TextEditingController()..text = '';

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton<String>(
              // Category dropdown
              value: _category,
              style: TextStyle(color: Colors.black),
              items: <String>[
                'Grocery',
                'Gift',
                'Household',
                'Utility',
                'Phone',
                'Internet',
                'HoA',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() => _category = value!);
              },
              hint: Text('Category'),
            ),
            DropdownButton<String>(
              // Merchant dropdown
              value: _merchant,
              style: TextStyle(color: Colors.black),
              items: <String>['Walmart', 'Trader Joe\'s', 'Ocean', 'Costco']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() => _merchant = value!);
              },
              hint: Text('Merchant'),
            ),
            TextFormField(
              // Amount text
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: false),
              controller: _amtController,
            ),
            ElevatedButton(
              onPressed: () {
                if (_category != '' &&
                    _merchant != '' &&
                    _amtController.text != '') {
                  Transaction t = new Transaction(
                    date,
                    _category,
                    _eventIcon,
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      color: Colors.red,
                      height: 5.0,
                      width: 5.0,
                    ),
                    _merchant,
                    double.parse(_amtController.text),
                  );
                  _amtController.clear();

                  Navigator.pop(
                      context, t); // return the newly create transaction
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
