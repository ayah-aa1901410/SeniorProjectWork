import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double bodyTemperature = 36.95;
  double spo2 = 96.0;
  double heartrate = 75.0;

  var result = "";

  @override
  void initState() {
    super.initState();
    // generateData();
  }

  // void generateData(){
  //   final random = Random();
  //   setState(() {
  //     bodyTemperature = 35.0 + random.nextDouble() * 4.0; //rangle 35 to 39.9
  //     spo2 = 0.95 + random.nextDouble() * 0.05; //range 95 to 100
  //     heartrate = 50.0 + random.nextDouble() * 50.0; //range 50 BPM to 100 BPM
  //   });
  // }

  void _classifyData() async {
    // final url = Uri.parse("http://192.168.10.8:7000/classify");
    final url = Uri.parse("http://192.168.10.44:7000/classify");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'body_temperature' : bodyTemperature,
      'spo2' : spo2,
      'heart_rate' : heartrate
    });

    final response = await http.post(url as Uri, headers: headers, body: body);
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        result = jsonResponse['result'];
      });
    } else {
      throw Exception('Failed to classify body vitals.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Body Temperature: " + bodyTemperature.toString(),
            ),
            Text(
              "Heartrate: " + heartrate.toString(),
            ),
            Text(
              "SPO2: " + spo2.toString(),
            ),
            // ElevatedButton(
            //   onPressed: generateData,
            //   child: Text(
            //     "Regenerate the Data"
            //   ),
            // ),
            ElevatedButton(
              onPressed: _classifyData,
              child: Text(
                  "Classify the Data"
              ),
            ),
            Text(
              "Result: " + result,
            ),
          ],
        ),
      ),
    );
  }
}
