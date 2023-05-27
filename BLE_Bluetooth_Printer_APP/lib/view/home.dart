import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:onemoretime/controller/health_data_controller.dart';
import 'package:onemoretime/view/heartrateChart.dart';
import 'package:onemoretime/view/spo2Chart.dart';
import '/view/takeTest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:onemoretime/view/bodytempChart.dart';
import 'package:ble_data_converter/ble_data_converter/src/ble_data_converter.dart';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:blue_thermal_printer/blue_thermal_printer.dart'as thermal;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();



TextEditingController spo2 = TextEditingController();
TextEditingController heartrate = TextEditingController();
TextEditingController bodytemperature = TextEditingController();

class Home extends StatefulWidget {
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

  String userHealth = "Healthy";
  bool notFound = false;

  bool calibrationDone = false;

  @override
  void initState() {
    super.initState();
    _user = auth.currentUser!;

    spo2.text = "-1";
    heartrate.text = "-1";
    bodytemperature.text = "-1";

    fetchLatestRecord();
    initPrinter();
  }

  //BLE related variables ----
  bool isConnected = false;
  bool _wristbandConnected = false;
  String connectionText = "Wristband Not Connected";

  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  // BluetoothDevice? esp32Device;

  double tempText = 0.0;
  int pulseText = 0;
  int spo2Text = 0;

  thermal.BlueThermalPrinter bluetooth = thermal.BlueThermalPrinter.instance;

  thermal.BluetoothDevice? _device;
  BluetoothCharacteristic? _tempCharacteristic;
  BluetoothCharacteristic? _pulseCharacteristic;
  BluetoothCharacteristic? _spo2Characteristic;

  Future<void> initPrinter() async {
    bool? isAvailable = await bluetooth.isAvailable;
    if (!isAvailable!) {
      print('Bluetooth is not available');
      return;
    }
    bool? isOn = await bluetooth.isOn;
    if (!isOn!) {
      print('Bluetooth is not turned on');
      return;
    }
    print('Bluetooth is available and turned on');
  }

  Future<void> connect() async {
    if (isConnected) {
      print('Already connected to a device.');
      return;
    }

    setState(() {
      isConnected = true;
    });

    try {
      List<thermal.BluetoothDevice> devices = await bluetooth.getBondedDevices();
      thermal.BluetoothDevice? esp32Device = devices.firstWhere((device) =>
      device.name == 'ESP32', orElse: () => null);

      if (esp32Device == null) {
        print('ESP32 device not found.');
        return;
      }

      _device = esp32Device;
      setState(() {
        _wristbandConnected = true;
        connectionText = 'Wristband Connected';
      });

      await bluetooth.connect(_device!);
      print('Connected to device: ${_device!.name}');

      List<BluetoothService> services = await _device!.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service
            .characteristics) {
          if (characteristic.uuid.toString() ==
              '860a3d66-eb23-11ed-a05b-0242ac120003') {
            _tempCharacteristic = characteristic;
            await bluetooth.subscribe(_device!, _tempCharacteristic!);
            bluetooth.onDataReceived.listen((data) {
              final tempValue = ByteData.sublistView(Uint8List.fromList(data))
                  .getFloat32(0, Endian.little);
              setState(() {
                tempText = tempValue;
              });
            });
          } else if (characteristic.uuid.toString() ==
              'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
            _pulseCharacteristic = characteristic;
            await bluetooth.subscribe(_device!, _pulseCharacteristic!);
            bluetooth.onDataReceived.listen((data) {
              final pulseValue = BLEDataConverter.i32.bytesToInt(data);
              setState(() {
                pulseText = pulseValue;
              });
            });
          } else if (characteristic.uuid.toString() ==
              '97cba7a6-eb23-11ed-a05b-0242ac120003') {
            _spo2Characteristic = characteristic;
            await bluetooth.subscribe(_device!, _spo2Characteristic!);
            bluetooth.onDataReceived.listen((data) {
              final spo2Value = BLEDataConverter.i32.bytesToInt(data);
              setState(() {

              });
            });
          }
        }
      }
    } catch(e){
      print('Error connecting to device: $e');
    }

  }

  void disconnect(){

  }

  // //BLE related functions -----
  // void connect() async {
  //   List<BluetoothService> services;
  //   if (isConnected) {
  //     print('Already connected to a device.');
  //     return;
  //   }
  //
  //   setState(() {
  //     isConnected = true;
  //   });
  //
  //   // Check if a connection is already established
  //   if (_device?.state == BluetoothDeviceState.connected) {
  //     print('Device is already connected.');
  //     return;
  //   }
  //
  //   // Search for the ESP32 device
  //   try{
  //     List<ScanResult> scanResults = await FlutterBluePlus.instance.startScan(
  //         timeout: const Duration(seconds: 15));
  //     print("These are the scan results: " );
  //     print(scanResults);
  //     for (ScanResult scanResult in scanResults) {
  //       print("${scanResult.device.name} found! rssi: ${scanResult.rssi}");
  //       print("THE RESULTS ARE IN: $scanResult");
  //       if (scanResult.device.name == "ESP32") {
  //         _device = scanResult.device;
  //         setState(() {
  //           _wristbandConnected = true;
  //           connectionText = "Wristband Connected";
  //         });
  //         break;
  //       } else {
  //         notFound = true;
  //       }
  //     }
  //   } catch (e){
  //     print(e);
  //   }
  //
  //
  //   if (_device == null) {
  //     print('ESP32 device not found.');
  //     return;
  //   }
  //
  //   try {
  //     await _device?.connect();
  //     print('Connected to device: ${_device?.name}');
  //
  //     // Discover services and characteristics of the connected device
  //     services = await _device!.discoverServices();
  //
  //     // Set up notifications for the characteristics
  //     for (BluetoothService service in services) {
  //       for (BluetoothCharacteristic characteristic in service.characteristics) {
  //         if (characteristic.uuid.toString() ==
  //             "860a3d66-eb23-11ed-a05b-0242ac120003") {
  //           _tempCharacteristic = characteristic;
  //           await _tempCharacteristic!.setNotifyValue(true);
  //           _tempCharacteristic!.value.listen((value) {
  //
  //             final tempValue = ByteData.sublistView(Uint8List.fromList(value)).getFloat32(0, Endian.little);
  //             setState(() {
  //               tempText = tempValue;
  //               bodytemperature.text = tempValue.toString();
  //               if(tempValue > 35.0){
  //                 calibrationDone = true;
  //               }
  //             });
  //           });
  //         } else if (characteristic.uuid.toString() ==
  //             "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
  //           _pulseCharacteristic = characteristic;
  //           await _pulseCharacteristic!.setNotifyValue(true);
  //           _pulseCharacteristic!.value.listen((value) {
  //             final pulseValue = BLEDataConverter.i32.bytesToInt(value);
  //             setState(() {
  //               pulseText = pulseValue;
  //               heartrate.text = pulseValue.toString();
  //             });
  //           });
  //         } else if (characteristic.uuid.toString() ==
  //             "97cba7a6-eb23-11ed-a05b-0242ac120003") {
  //           _spo2Characteristic = characteristic;
  //           await _spo2Characteristic!.setNotifyValue(true);
  //           _spo2Characteristic!.value.listen((value) {
  //             final spo2Value = BLEDataConverter.i32.bytesToInt(value);
  //             setState(() {
  //               spo2Text = spo2Value;
  //               spo2.text = spo2Value.toString();
  //             });
  //           });
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Error connecting to device: $e');
  //   }
  // }
  //
  // void disconnect() {
  //   if (_device != null) {
  //     String deviceName = _device!.name ?? 'unknown device';
  //     print('Disconnected from $deviceName');
  //     _device!.disconnect();
  //   }
  //   setState(() {
  //     isConnected = false;
  //     _wristbandConnected = false;
  //     notFound == false;
  //     connectionText = "Wristband Not Connected";
  //   });
  // }

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

  @override
  void dispose(){
    notFound = false;
    disconnect();
    fetchLatestRecord();
    super.dispose();
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

    String connectedDeviceName = _device?.name ?? '...'; // Default value if device is not connected
    String connectionStatus = isConnected ? 'Connected to device $connectedDeviceName' : 'Disconnected from $connectedDeviceName';

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
                                          color: _wristbandConnected
                                              ? const Color.fromRGBO(
                                                  65, 161, 145, 1.0)
                                              : const Color.fromRGBO(
                                                  213, 23, 31, 1.0)),
                                    ), //This text will display whether the Wristband is connected or not.
                                    const SizedBox(height: 10),
                                    Visibility(
                                      visible: !calibrationDone && _wristbandConnected,
                                        child: const Text(
                                          "Calibration in Process",
                                          style: TextStyle(
                                              decoration: TextDecoration.underline,
                                              fontSize: 20,
                                              color:  Color.fromRGBO(229, 127, 132, 1.0),
                                          ),
                                        ), //This t
                                    ),
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
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color.fromRGBO(65, 161, 145, 1.0),
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
                                          onPressed: isConnected ? null : connect,
                                          child: Text('Connect'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color.fromRGBO(47, 80, 97, 1.0),
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
                                          onPressed: isConnected ? disconnect : null,
                                          child: Text('Disconnect'),
                                        ),
                                      ],
                                    ),
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
                                disconnect();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TakeTest(),
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



  getHealthColor(String userHealth) {
    if (userHealth == "healthy" || userHealth == "Healthy") {
      return const Color.fromRGBO(65, 161, 145, 1.0);
    } else if (userHealth == "Symptomatic") {
      return Colors.yellow[700];
    } else if (userHealth == "covid-19" || userHealth == "COVID-19") {
      return const Color.fromRGBO(229, 127, 132, 1.0);
    } else {
      return Colors.blueGrey[100];
    }
  }
}

