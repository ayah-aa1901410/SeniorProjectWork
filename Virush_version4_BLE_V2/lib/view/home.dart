import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virush_version2/controller/health_data_controller.dart';
import 'package:virush_version2/view/heartrateChart.dart';
import 'package:virush_version2/view/spo2Chart.dart';
import '/view/takeTest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bodytempChart.dart';
import 'package:ble_data_converter/ble_data_converter/src/ble_data_converter.dart';
import 'dart:typed_data';

bool _NFCconnected = false;
String connectionText = 'Wristband Not Connected';

TextEditingController spo2 = TextEditingController();
TextEditingController heartrate = TextEditingController();
TextEditingController bodytemperature = TextEditingController();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

//Todo
class _HomeState extends State<Home> {
  final rowSpacer = const TableRow(children: [
    SizedBox(
      height: 10,
    ),
    SizedBox(
      height: 10,
    ),
    SizedBox(
      height: 10,
    ),
  ]);

  /*
  User and Firestore Initialization:
  */
  FirebaseAuth auth = FirebaseAuth.instance;
  late final User _user;
  final CollectionReference recordsRef =
      FirebaseFirestore.instance.collection('records');

  BluetoothDevice? device;

  /*
  the variables that will be displayed in the dashboard Health Meters
   */

  String userHealth = "Healthy";

  @override
  void initState() {
    super.initState();
    _user = auth.currentUser!;

    spo2.text = "-1";
    heartrate.text = "-1";
    bodytemperature.text = "-1";
    fetchLatestRecord();
  }

  /*
  This function is used to fetch the data in the latest user record. We display the latest Health State in the first Card on the HomeScreen.
   */
  Future<void> fetchLatestRecord() async {
    final QuerySnapshot querySnapshot = await recordsRef
        .where('uid', isEqualTo: _user.uid)
        .orderBy('current_date_time', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.size > 0) {
      final latestRecord = querySnapshot.docs.first;
      final Map<String, dynamic>? latestRecordData =
          latestRecord.data() as Map<String, dynamic>?;
      if (latestRecordData != null) {
        // spo2.text = "${latestRecordData['spo2']}";
        // heartrate.text = "${latestRecordData['heart_rate']}";
        // bodytemperature.text = "${latestRecordData['body_temperature']}";
        userHealth = "${latestRecordData['overall_health']}";
        //print("jgrrrrr");
        setState(() {
          // spo2 = spo2;
          // heartrate = heartrate;
          // bodytemperature = bodytemperature;
          userHealth = userHealth;
        });
      }
      print(latestRecord.data());
    } else {
      // spo2.text = "-1";
      // heartrate.text = "-1";
      // bodytemperature.text = "-1";
      userHealth = "--";
      setState(() {
        // spo2 = spo2;
        // heartrate = heartrate;
        // bodytemperature = bodytemperature;
        userHealth = userHealth;
      });
      print('No records found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4EAE6),
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 15,
                                ),
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                // color: Colors.blueGrey[100],
                                color: const Color(0xFFFFFFFFF),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            'Overall Health',
                                            style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                  47, 80, 97, 1.0),
                                            ),
                                          ),
                                          //const SizedBox(height: 10),
                                          Icon(
                                            Icons.circle,
                                            color: getHealthColor(userHealth),
                                            size: 80,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.water_drop_rounded,
                                                color: Colors.red[300],
                                                size: 25,
                                              ),
                                              Text(
                                                "COVID-19",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      47, 80, 97, 1.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.water_drop_rounded,
                                                color: Colors.yellow[700],
                                                // color: Color.fromRGBO(242, 212, 60, 1.0),
                                                size: 25,
                                              ),
                                              Text(
                                                "Symptomatic",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      47, 80, 97, 1.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.water_drop_rounded,
                                                color: const Color.fromRGBO(
                                                    65, 161, 145, 1.0),
                                                size: 25,
                                              ),
                                              Text(
                                                "Healthy",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      47, 80, 97, 1.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                            Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 15,
                              ),
                              elevation: 7,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              color: const Color(0xFFFFFFFF),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    5.0, 10.0, 5.0, 10.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Vital Signs',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(47, 80, 97, 1.0),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      connectionText,
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 18,
                                          color: _NFCconnected
                                              ? const Color.fromRGBO(
                                                  65, 161, 145, 1.0)
                                              : const Color.fromRGBO(
                                                  213, 23, 31, 1.0)),
                                    ), //This text will display whether the Wristband is connected or not.
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SpO2Indicator(
                                              spo2Level: int.parse(spo2.text),
                                            ), //int.parse(spo2.text)),
                                            HeartRateIndicator(
                                              heartRate:
                                                  int.parse(heartrate.text),
                                            ),
                                          ],
                                        ),
                                        ThermometerGauge(
                                          value: double.parse(
                                              bodytemperature.text),
                                        ),
                                      ],
                                    ),
                                    // ElevatedButton(
                                    //   onPressed: _buildScanButton(),
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: const Color.fromRGBO(
                                    //         47, 80, 97, 1.0),
                                    //     elevation: 7,
                                    //     minimumSize: Size(130, 40),
                                    //     textStyle: TextStyle(fontSize: 17),
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(15.0),
                                    //     ),
                                    //   ),
                                    //   child: const Text(
                                    //     'Search for Wristband',
                                    //     style: TextStyle(
                                    //       fontWeight: FontWeight.bold,
                                    //       fontFamily: 'Tinos-Bold',
                                    //     ),
                                    //   ),
                                    //   // onPressed: healthDataController.readData(),
                                    // )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(229, 127, 132, 1.0),
                                // fixedSize: const Size(
                                //   110,
                                //   40,
                                // ),
                                elevation: 7,
                                minimumSize: Size(130, 40),
                                textStyle: TextStyle(fontSize: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  // side: const BorderSide(
                                  //   color: Color(0xFFF4EAE6),
                                  // ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TakeTest(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Take Test",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tinos-Bold",
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 15,
                                ),
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                color: const Color(0xFFFFFFFF),
                                child: SizedBox(
                                  width: 350,
                                  height: 180,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        5.0, 10.0, 5.0, 10.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          _buildScanResultsList(),
                                          _buildScanButton()
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildScanResultsList() {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBluePlus.instance.scanResults,
      initialData: const [],
      builder: (context, snapshot) {
        final scanResults = snapshot.data!;
        final esp32Results = scanResults
            .where((result) => result.device.name == "ESP32")
            .toList();
        return Column(
          children: esp32Results.map((result) {
            result.device.connect(); // Connect to the device
            return Card(
              child: DeviceScreen(
                  device: result
                      .device), // Return the DeviceScreen widget wrapped in a Card
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
          width: 180,
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: isScanning
                ? const Icon(Icons.stop)
                : const Text('Connect to wristband'),
            onPressed: () {
              FlutterBluePlus.instance
                  .startScan(timeout: const Duration(seconds: 4));
            },
          ),
        );
      },
    );
  }

  getHealthColor(String userHealth) {
    if (userHealth == "healthy") {
      return const Color.fromRGBO(65, 161, 145, 1.0);
    } else if (userHealth == "Symptomatic") {
      return Colors.yellow[700];
    } else if (userHealth == "covid-19") {
      return const Color.fromRGBO(229, 127, 132, 1.0);
    } else {
      return Colors.blueGrey[100];
    }
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
        _NFCconnected = true;
        connectionText = "Wristband Connected";
      });
    } catch (e) {
      print('Error discovering services: $e');
    }
  }

  void _listenToDeviceStateChanges() {
    _deviceStateSubscription = widget.device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        _reconnectDevice();
        setState(() {
          _NFCconnected = false;
          connectionText = "Wristband Not Connected";
        });
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
      {Key? key, required this.characteristic, this.onNotificationPressed})
      : super(key: key);

  // Declare variables to store values
  double tempValue = 0.0;
  int heartRateValue = 0;
  int spO2Value = 0;
  dynamic value1;

  @override
  Widget build(BuildContext context) {
    String title;

    if (characteristic.uuid.toString() ==
        "860a3d66-eb23-11ed-a05b-0242ac120003") {
      title = 'temp';
    } else if (characteristic.uuid.toString() ==
        "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
      title = 'heart rate';
    } else if (characteristic.uuid.toString() ==
        "97cba7a6-eb23-11ed-a05b-0242ac120003") {
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
        if (title == 'temp' && value != null && value.isNotEmpty) {
          value1 = ByteData.view(Uint8List.fromList(List.from(value)).buffer)
              .getFloat32(0, Endian.little);
          bodytemperature = value1;
          print("temp: $value1");
        } else if (title == 'heart rate' && value != null && value.isNotEmpty) {
          heartRateValue = BLEDataConverter.i32.bytesToInt(value);
          value1 = heartRateValue;
          heartrate = value1;
          print("heartRateValue: $value1");
        } else if (title == 'sp02' && value != null && value.isNotEmpty) {
          spO2Value = BLEDataConverter.i32.bytesToInt(value);
          value1 = spO2Value;
          spo2 = value1;
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
