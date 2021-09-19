import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense/transaction.dart';
import 'package:expense/receipt.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

class NewTransactionScreen extends StatefulWidget {
  NewTransactionScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NewTransactionScreenState createState() =>
      new _NewTransactionScreenState(title);
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  _NewTransactionScreenState(this.title);

  final categories = [
    'Grocery',
    'Gift',
    'Household',
    'Utility',
    'Phone',
    'Internet',
    'HoA'
  ];
  final vendors = ['Walmart', 'Trader Joe\'s', 'Ocean', 'Costco'];
  final frequency = ['Monthly', 'Semi anuually'];
  final String title;
  double budget = 0;
  late TextEditingController _descController;
  String _category = '', _vendor = '', _frequency = '';
  String _receiptImgPath = '';

  @override
  void initState() {
    _category = categories[0];
    _vendor = vendors[0];
    _frequency = frequency[0];
    super.initState();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    // Disposing the text detector when not used anymore
    super.dispose();
  }

  Future<void> recogniseText() async {
    final GoogleVisionImage visionImage =
        GoogleVisionImage.fromFile(File(_receiptImgPath));
    final TextRecognizer textRecognizer =
        GoogleVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          print(element.text);
        }
      }
    }
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
      setState(() => _receiptImgPath = path);
      recogniseText();
    }
  }

  Widget showReceipt() {
    return File(_receiptImgPath).existsSync()
        ? Container(
            // display the receipt image
            padding: EdgeInsets.zero,
            height: 150,
            width: 150,
            child: Image.file(File(_receiptImgPath)),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Transaction;
    String _amount = args.amount.toString();
    if (args.category.isNotEmpty) _category = args.category;
    if (args.vendor.isNotEmpty) _vendor = args.vendor;
    if (args.frequency.isNotEmpty) _frequency = args.frequency;

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
                    items: categories
                        .map<DropdownMenuItem<String>>((String value) {
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
                    // Vendor dropdown
                    value: _vendor,
                    style: TextStyle(color: Colors.black),
                    items:
                        vendors.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() => _vendor = value!);
                    },
                    hint: Text('Vendor'),
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
                      onChanged: (amt) {
                        _amount = amt;
                      },
                    ),
                  ),
                  DropdownButton<String>(
                    // Repeat dropdown
                    value: _frequency,
                    style: TextStyle(color: Colors.black),
                    items:
                        frequency.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() => _frequency = value!);
                    },
                    icon: const Icon(Icons.repeat),
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
            showReceipt(),
            Container(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Visibility(
                      child: ElevatedButton(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red))),
                          ),
                          onPressed: () {
                            Navigator.pop(
                                context,
                                Transaction
                                    .empty()); // return an empty transaction
                          }),
                      visible: args.category.isNotEmpty ? true : false),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
          child: FloatingActionButton.extended(
            elevation: 0.0,
            backgroundColor: new Color(0xFFE57373),
            onPressed: () {
              if (_category != '' && _amount != '') {
                Transaction t = new Transaction(
                  _category,
                  _vendor,
                  double.parse(_amount),
                  _frequency,
                );
                Navigator.pop(
                    context, t); // return the newly create transaction
              }
            },
            label: const Text('Save'),
          ),
          visible: args.category.isEmpty ? true : false),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
