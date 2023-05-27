import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble_data_converter/ble_data_converter/src/ble_data_converter.dart';
import 'dart:typed_data';


void main() {
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FindDevicesScreen(),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
      ),
      body: Card(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildScanResultsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildScanButton(),
    );
  }

  Widget _buildScanResultsList() {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBluePlus.instance.scanResults,
      initialData: const [],
      builder: (context, snapshot) {
        final scanResults = snapshot.data!;
        final esp32Results = scanResults.where((result) => result.device.name == "ESP32").toList();
        return Column(
          children: esp32Results.map((result) {
            result.device.connect(); // Connect to the device
            return Card(
              child: DeviceScreen(device: result.device), // Return the DeviceScreen widget wrapped in a Card
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildScanButton() {
    return StreamBuilder<bool>(
      stream: FlutterBluePlus.instance.isScanning,
      initialData: false,
      builder: (context, snapshot) {
        final isScanning = snapshot.data!;
        return SizedBox(
          width: double.infinity,
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: isScanning ? const Icon(Icons.stop) : const Text('Connect to wristband'),
            onPressed: () {
              FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4));
            },
          ),
        );

      },
    );
  }



}

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService>? _services;

  StreamSubscription? _deviceStateSubscription;

  @override
  void initState() {
    super.initState();
    _discoverServices();
    _listenToDeviceStateChanges();
  }

  Future<void> _discoverServices() async {
    try {
      await widget.device.connect();
      List<BluetoothService> services = await widget.device.discoverServices();
      setState(() {
        _services = services;
      });
    } catch (e) {
      print('Error discovering services: $e');
    }
  }

  void _listenToDeviceStateChanges() {
    _deviceStateSubscription = widget.device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        _reconnectDevice();
      }
    });
  }

  void _reconnectDevice() async {
    if (_deviceStateSubscription != null) {
      _deviceStateSubscription!.cancel();
      _deviceStateSubscription = null;
    }

    await widget.device.disconnect();
    await widget.device.connect();
    _listenToDeviceStateChanges();
    _discoverServices();
  }

  @override
  void dispose() {
    _deviceStateSubscription?.cancel();
    super.dispose();
  }

  List<Widget> _buildServiceTiles() {
    if (_services != null) {
      return _services!
          .map(
            (s) => ServiceTile(
          service: s,
          characteristicTiles: s.characteristics
              .map(
                (c) => CharacteristicTile(
              characteristic: c,
              onNotificationPressed: () async {
                await c.setNotifyValue(!c.isNotifying);
                await c.read();
              },
            ),
          )
              .toList(),
        ),
      )
          .toList();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                title: Text(
                  'Device is ${snapshot.data.toString().split('.')[1]}.',
                ),
                trailing: StreamBuilder<bool>(
                  stream: widget.device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _discoverServices,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_services != null)
              Column(
                children: _buildServiceTiles(),
              ),
          ],
        ),
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({
    Key? key,
    required this.service,
    required this.characteristicTiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (service.uuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...characteristicTiles,
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final VoidCallback? onNotificationPressed;

  CharacteristicTile(
      {Key? key,
        required this.characteristic,
        this.onNotificationPressed})
      : super(key: key);

  // Declare variables to store values
  double tempValue = 0.0;
  int heartRateValue = 0;
  int spO2Value = 0;
  dynamic value1;


  @override
  Widget build(BuildContext context) {
    String title;

    if (characteristic.uuid.toString() == "860a3d66-eb23-11ed-a05b-0242ac120003") {
      title = 'temp';
    } else if (characteristic.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
      title = 'heart rate';
    } else if (characteristic.uuid.toString() == "97cba7a6-eb23-11ed-a05b-0242ac120003") {
      title = 'sp02';
    } else {
      title = 'Characteristic';
    }

    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        // Assign values to variables based on the title
        if (title == 'temp' && value!=null && value.isNotEmpty) {
          value1 = ByteData.view(Uint8List.fromList(List.from(value)).buffer).getFloat32(0, Endian.little);
          print("temp: $value1");
        } else if (title == 'heart rate' && value!=null && value.isNotEmpty) {
          heartRateValue = BLEDataConverter.i32.bytesToInt(value);
          value1 = heartRateValue;
          print("heartRateValue: $value1");
        } else if (title == 'sp02' && value!=null && value.isNotEmpty) {
          spO2Value = BLEDataConverter.i32.bytesToInt(value);
          value1 = spO2Value;
          print("sp02: $value1");
        }

        return ExpansionTile(
          title: ListTile(
            title: Column(
              children: <Widget>[
                Text(title),
              ],
            ),
            subtitle: Text(value1?.toString() ?? 'N/A'),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                    characteristic.isNotifying
                        ? Icons.sync_disabled
                        : Icons.sync,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                onPressed: onNotificationPressed,
              )
            ],
          ),
        );
      },
    );
  }
}

