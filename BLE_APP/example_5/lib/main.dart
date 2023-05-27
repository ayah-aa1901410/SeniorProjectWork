import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final title = 'BLE Set Notification';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    initBle();
  }

  void initBle() {
    flutterBlue.isScanning.listen((isScanning) {
      setState(() {
        _isScanning = isScanning;
      });
    });
  }

  void scan() async {
    if (!_isScanning) {
      scanResultList.clear();
      try {
        await flutterBlue.startScan(timeout: Duration(seconds: 4));
        flutterBlue.scanResults.listen((results) async {
          for (ScanResult r in results) {
            if (r.device.name == "ESP32") {
              print("Found device: ${r.device.name}");
              await flutterBlue.stopScan();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeviceScreen(device: r.device)),
              );
              break;
            }
          }
        });
      } catch (e) {
        print(e);
      }
    } else {
      flutterBlue.stopScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _isScanning
            ? CircularProgressIndicator()
            : Text('Press the Search button to start scanning'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: scan,
            child: Text(
              'Search for your wristband',
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
