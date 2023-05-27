import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _counter = 0;
  int spo2 = -1;
  int bodyTemp = -1;
  int heartRate = -1;

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }
  void _updateData() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Transmitted Data"),
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 30.0),
                  Text("Bidy Temperature"),
                  Text("$bodyTemp"),
                  SizedBox(height: 30.0),
                  Text("SPO2 level"),
                  Text("$spo2"),
                  SizedBox(height: 30.0),
                  Text("Heart Rate"),
                  Text("$heartRate"),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: _updateData,
                    child: Text("Submit"),
                  ),
                  SizedBox(height: 16.0),
                  Text("Button pressed $_counter times"),
                ],
              ),
            )),
      ),
    );
  }
}
