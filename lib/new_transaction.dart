import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense/transaction.dart';
import 'package:expense/receipt.dart';
import 'package:camera/camera.dart';

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
  _NewTransactionScreenState createState() =>
      new _NewTransactionScreenState(title);
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  _NewTransactionScreenState(this.title);

  final String title;
  double budget = 0;
  late TextEditingController _amtController, _descController;
  String _category = '', _merchant = '';
  String receiptImgPath = '';

  @override
  void initState() {
    super.initState();
    _amtController = TextEditingController();
    _descController = TextEditingController();
  }

  Future<void> addReceipt(BuildContext context) async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    final path = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: firstCamera),
      ),
    );

    if (path != null) {
      setState(() => receiptImgPath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ModalRoute.of(context)!.settings.arguments as DateTime;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    items: <String>[
                      'Walmart',
                      'Trader Joe\'s',
                      'Ocean',
                      'Costco'
                    ].map<DropdownMenuItem<String>>((String value) {
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
                ],
              ),
            ),
            Container(
              child: new Row(
                children: <Widget>[
                  new Flexible(
                    child: new TextField(
                      // Amount text
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Amount',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      controller: _amtController,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Flexible(
                    child: new TextField(
                      // Description text
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Description',
                      ),
                      controller: _descController,
                    ),
                  ),
                  IconButton(
                    // camera button
                    icon: const Icon(Icons.camera_alt),
                    iconSize: 20,
                    color: Colors.black,
                    splashColor: Colors.purple,
                    onPressed: () {
                      addReceipt(context);
                    },
                  ),
                ],
              ),
            ),
            Container(
              // display the receipt image
              padding: EdgeInsets.zero,
              height: 150,
              width: 150,
              child: Image.file(File(receiptImgPath)),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.check),
          backgroundColor: new Color(0xFFE57373),
          onPressed: () {
            if (_category != '' && _amtController.text != '') {
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
                receiptImgPath,
              );
              _amtController.clear();
              Navigator.pop(context, t); // return the newly create transaction
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
