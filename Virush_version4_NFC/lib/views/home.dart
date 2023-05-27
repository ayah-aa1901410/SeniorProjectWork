import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virush_version2/controller/health_data_controller.dart';
import 'package:virush_version2/views/heartrateChart.dart';
import 'package:virush_version2/views/spo2Chart.dart';
import '/views/takeTest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bofytempChart.dart';
import 'package:ble_data_converter/ble_data_converter/src/ble_data_converter.dart';

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

  /*
  BLE Initialization:
  */
  BluetoothDevice? device;
  /*
  The variable below is displayed in the second Card on the Home Page. It shows that the wristband is connected or not. Therefore, while creating the BLE functions,
  if you see that the wristband is connected, then:
   setState(() {
        _NFCConnected = true;
        connectionText = "Wristband Connected";
   });
   */

  bool _NFCconnected = false;
  var connectionText = "Wristband not connected";
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  List<BluetoothService> bluetoothService = [];
  Map<String, List<int>> notifyDatas = {};
  List<ScanResult> scanResultList = [];
  bool _isScanning = false;
  bool _isConnected = false;
  String stateText = 'Connecting';
  String connectButtonText = 'Disconnect';


  /*
  the variables that will be displayed in the dashboard Health Meters
   */
  TextEditingController spo2 = TextEditingController();
  TextEditingController heartrate = TextEditingController();
  TextEditingController bodytemperature = TextEditingController();

  String userHealth = "Healthy";

  final healthDataController = Get.put(HealthDataController());


  @override
  void initState() {
    super.initState();
    _user = auth.currentUser!;

    spo2.text = "-1";
    heartrate.text = "-1";
    bodytemperature.text = "-1";
    fetchLatestRecord();

    /*
    initializing functions for BLE
     */
    initBle();
    getHealthData();

  }

  void initBle() {
    flutterBlue.isScanning.listen((isScanning) {
      setState(() {
        _isScanning = isScanning;
      });
    });
  }

  /*
  This function has the content of the -> scan() function
   */
  void getHealthData() async {
    // List<SensorData> sensorDataList =
    //     await healthDataController.getHealthData();
    if (!_isScanning) {
      scanResultList.clear();
      try {
        await flutterBlue.startScan(timeout: Duration(seconds: 4));
        flutterBlue.scanResults.listen((results) async {
          for (ScanResult r in results) {
            if (r.device.name == "ESP32") {
              print("Found device: ${r.device.name}");
              setState(() async {
                device = r.device;
                setBleConnectionState(deviceState);
                _isConnected = await connect();
                _NFCconnected = true;
                connectionText = "Wristband Connected";
              });
              await flutterBlue.stopScan();
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

    /*
    checking if the wristband is connected and if yes, initializing the variables that will appear on the screen
     */
    if(_isConnected){
      setState(() {
        _NFCconnected = true;
        connectionText = "Wristband Connected";
        if(notifyDatas["860a3d66-eb23-11ed-a05b-0242ac120003"] != null && notifyDatas["860a3d66-eb23-11ed-a05b-0242ac120003"]!.isNotEmpty ){
          heartrate.text = notifyDatas["860a3d66-eb23-11ed-a05b-0242ac120003"].toString();
        }

        if(notifyDatas["beb5483e-36e1-4688-b7f5-ea07361b26a8"] != null && notifyDatas["beb5483e-36e1-4688-b7f5-ea07361b26a8"]!.isNotEmpty ){
          bodytemperature.text = notifyDatas["beb5483e-36e1-4688-b7f5-ea07361b26a8"].toString();
        }

        if(notifyDatas["97cba7a6-eb23-11ed-a05b-0242ac120003"] != null && notifyDatas["97cba7a6-eb23-11ed-a05b-0242ac120003"]!.isNotEmpty ){
          spo2.text = notifyDatas["97cba7a6-eb23-11ed-a05b-0242ac120003"].toString();
        }
      });
    }else{
      setState(() {
        _NFCconnected = false;
        connectionText = "Wristband not connected";
      });
    }

    // if (sensorDataList[0].data == '-1' &&
    //     sensorDataList[1].data == '-1' &&
    //     sensorDataList[2].data == '-1') {
    //   setState(() {
    //     _NFCconnected = false;
    //     connectionText = "Wristband not connected";
    //   });
    // } else {
    //   setState(() {
    //     _NFCconnected = true;
    //     connectionText = "Wristband Connected";
    //   });
    //
    //   heartrate.text = sensorDataList[0].data;
    //   bodytemperature.text = sensorDataList[1].data;
    //   spo2.text = sensorDataList[2].data;
    // }

  }

  /*
  function being called inside getHealthData() when device is located
   */
  setBleConnectionState(BluetoothDeviceState event) {
    switch (event) {
      case BluetoothDeviceState.disconnected:
        stateText = 'Disconnected';
        connectButtonText = 'Connect';
        break;
      case BluetoothDeviceState.disconnecting:
        stateText = 'Disconnecting';
        break;
      case BluetoothDeviceState.connected:
        stateText = 'Connected';
        connectButtonText = 'Disconnect';
        break;
      case BluetoothDeviceState.connecting:
        stateText = 'Connecting';
        break;
    }

    deviceState = event;
    setState(() {});
  }

  /*
  function being called inside getHealthData() after setBleConnectionState()
   */
  Future<bool> connect() async {
    Future<bool>? returnValue;
    setState(() {
      stateText = 'Connecting';
    });

    await device
        ?.connect(autoConnect: false)
        .timeout(Duration(milliseconds: 15000), onTimeout: () {

      returnValue = Future.value(false);
      debugPrint('timeout failed');


      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) async {
      bluetoothService.clear();
      if (returnValue == null) {

        debugPrint('connection successful');
        print('start discover service');
        List<BluetoothService>? bleServices =
        await device?.discoverServices();
        setState(() {
          bluetoothService = bleServices!;
        });

        for (BluetoothService service in bleServices!) {
          print('============================================');
          print('Service UUID: ${service.uuid}');
          for (BluetoothCharacteristic c in service.characteristics) {

            if (c.properties.notify && c.descriptors.isNotEmpty) {

              for (BluetoothDescriptor d in c.descriptors) {
                print('BluetoothDescriptor uuid ${d.uuid}');
                if (d.uuid == BluetoothDescriptor.cccd) {
                  print('d.lastValue: ${d.lastValue}');
                }
              }


              if (!c.isNotifying) {
                try {
                  await c.setNotifyValue(true);

                  notifyDatas[c.uuid.toString()] = List.empty();
                  c.value.listen((value) {

                    int intValue = BLEDataConverter.i32.bytesToInt(value);
                    print('${c.uuid}: $intValue');
                    setState(() {
                      notifyDatas[c.uuid.toString()] = [intValue];
                    });
                  });

                  await Future.delayed(const Duration(milliseconds: 1000));
                } catch (e) {
                  print('error ${c.uuid} $e');
                }
              }
            }
          }
        }
        returnValue = Future.value(true);
      }
    });

    return returnValue ?? Future.value(false);
  }


  /*
  for now, this function is not being called.
   */
  void disconnect() {
    try {
      setState(() {
        stateText = 'Disconnecting';
      });
      device?.disconnect();
    } catch (e) {}
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
                            // Card(
                            //   margin: const EdgeInsets.symmetric(
                            //     vertical: 10,
                            //     horizontal: 15,
                            //   ),
                            //   color: Colors.blueGrey[100],
                            //   child: Row(
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       // Column(
                            //       //   children: [
                            //       //     const Icon(
                            //       //       Icons.circle,
                            //       //       color: Colors.teal,
                            //       //       size: 106,
                            //       //     ),
                            //       //     Image.asset(
                            //       //       'assets/images/health_scale.png',
                            //       //       width: 100,
                            //       //       height: 60,
                            //       //     ),
                            //       //   ],
                            //       // ),
                            //       // const SizedBox(
                            //       //   height: 140.0,
                            //       //   child: VerticalDivider(
                            //       //     thickness: 1.0,
                            //       //     width: 6.0,
                            //       //     color: Colors.blueGrey,
                            //       //   ),
                            //       // ),
                            //       //Vital Signs table
                            //       Padding(
                            //         padding: const EdgeInsets.all(8.0),
                            //         child: Column(
                            //           children: [
                            //             const Text(
                            //               'Vital Signs',
                            //               style: TextStyle(
                            //                   fontSize: 20,
                            //                   fontWeight: FontWeight.bold),
                            //             ),
                            //             const SizedBox(height: 10),
                            //             Table(
                            //               defaultColumnWidth:
                            //                   const FixedColumnWidth(100.0),
                            //               children: [
                            //                 TableRow(children: [
                            //                   const Padding(
                            //                     padding: EdgeInsets.all(8.0),
                            //                     child: Text(
                            //                       "SPO2",
                            //                       textAlign: TextAlign.center,
                            //                     ),
                            //                   ),
                            //                   Padding(
                            //                     padding: EdgeInsets.all(8.0),
                            //                     child: Text(
                            //                       "${spo2.text} %",
                            //                       textAlign: TextAlign.center,
                            //                     ),
                            //                   ),
                            //                   Image(
                            //                     image: AssetImage(
                            //                         'assets/images/spo2_icon.png'),
                            //                     width: 30.0,
                            //                     height: 30.0,
                            //                   ),
                            //                 ]),
                            //                 rowSpacer,
                            //                 TableRow(children: [
                            //                   Padding(
                            //                     padding: EdgeInsets.all(8.0),
                            //                     child: Text(
                            //                       "Heart Rate",
                            //                       textAlign: TextAlign.center,
                            //                     ),
                            //                   ),
                            //                   Padding(
                            //                     padding: EdgeInsets.all(8.0),
                            //                     child: Text(
                            //                       heartrate.text,
                            //                       textAlign: TextAlign.center,
                            //                     ),
                            //                   ),
                            //                   Padding(
                            //                     padding: EdgeInsets.all(8.0),
                            //                     child: Image(
                            //                       image: AssetImage(
                            //                           "assets/images/heartrate_icon.png"),
                            //                       width: 25.0,
                            //                       height: 25.0,
                            //                     ),
                            //                   ),
                            //                 ]),
                            //                 rowSpacer,
                            //                 TableRow(children: [
                            //                   Text(
                            //                     "Body Temperature",
                            //                     textAlign: TextAlign.center,
                            //                   ),
                            //                   Padding(
                            //                     padding: EdgeInsets.all(8.0),
                            //                     child: Text(
                            //                       bodytemperature.text,
                            //                       textAlign: TextAlign.center,
                            //                     ),
                            //                   ),
                            //                   Image(
                            //                     image: AssetImage(
                            //                         "assets/images/bodytemp_icon.png"),
                            //                     width: 25.0,
                            //                     height: 25.0,
                            //                   ),
                            //                 ]),
                            //               ],
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
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
                                            color:
                                            Color.fromRGBO(47, 80, 97, 1.0),
                                          ),
                                        ),
                                        //const SizedBox(height: 10),
                                        Icon(
                                          Icons.circle,
                                          color: getHealthColor(userHealth),
                                          size: 80,
                                        ),
                                        // Table(
                                        //   defaultColumnWidth:
                                        //       const FixedColumnWidth(100.0),
                                        //   children: [
                                        //     TableRow(children: [
                                        //       const Padding(
                                        //         padding: EdgeInsets.all(8.0),
                                        //         child: Text(
                                        //           "SPO2",
                                        //           textAlign: TextAlign.center,
                                        //         ),
                                        //       ),
                                        //       Padding(
                                        //         padding: EdgeInsets.all(8.0),
                                        //         child: Text(
                                        //           "${spo2.text} %",
                                        //           textAlign: TextAlign.center,
                                        //         ),
                                        //       ),
                                        //       Image(
                                        //         image: AssetImage(
                                        //             'assets/images/spo2_icon.png'),
                                        //         width: 30.0,
                                        //         height: 30.0,
                                        //       ),
                                        //     ]),
                                        //   ],
                                        // ),
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
                              )
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
                                    ElevatedButton(
                                      onPressed: getHealthData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            47, 80, 97, 1.0),
                                        elevation: 7,
                                        minimumSize: Size(130, 40),
                                        textStyle: TextStyle(fontSize: 17),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Search for Wristband',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Tinos-Bold',
                                        ),
                                      ),
                                      // onPressed: healthDataController.readData(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            // const SizedBox(
                            //   height: 150,
                            // ),
                            // Image.asset(
                            //   "assets/images/health_overview.PNG",
                            //   width: 350,
                            // ),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Positioned(
            //     bottom: 25.0,
            //     left: 0,
            //     right: 0,
            //     child: Padding(
            //       padding: EdgeInsets.fromLTRB(120, 0, 120, 0),
            //       child: SizedBox(
            //         width: 40,
            //         height: 40,
            //         child: FloatingActionButton(
            //           mini: true,
            //           materialTapTargetSize: MaterialTapTargetSize.padded,
            //           backgroundColor: Color.fromRGBO(229, 127, 132, 1.0),
            //           elevation: 5,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(13.0),
            //           ),
            //           onPressed: () {
            //             Navigator.of(context).push(
            //               MaterialPageRoute(
            //                 builder: (context) => const TakeTest(),
            //               ),
            //             );
            //           },
            //           child: const Text(
            //             "Take Test",
            //             style: TextStyle(
            //                 fontWeight: FontWeight.bold, fontSize: 20),
            //             textAlign: TextAlign.center,
            //           ),
            //           // ElevatedButton(
            //           //   style: ElevatedButton.styleFrom(
            //           //     backgroundColor: const Color.fromRGBO(229, 127, 132, 1.0),
            //           //     // fixedSize: const Size(
            //           //     //   110,
            //           //     //   40,
            //           //     // ),
            //           //     elevation: 7,
            //           //     minimumSize: Size(130, 40),
            //           //     textStyle: TextStyle(fontSize: 17),
            //           //     shape: RoundedRectangleBorder(
            //           //       borderRadius: BorderRadius.circular(15.0),
            //           //       // side: const BorderSide(
            //           //       //   color: Color(0xFFF4EAE6),
            //           //       // ),
            //           //     ),
            //           //   ),
            //           //   onPressed: () {
            //           //     Navigator.of(context).push(
            //           //       MaterialPageRoute(
            //           //         builder: (context) => const TakeTest(),
            //           //       ),
            //           //     );
            //           //   },
            //           //   child: const Text("Take Test", style: TextStyle(fontWeight: FontWeight.bold,),),
            //           // ),
            //         ),
            //       ),
            //     )),
          ],
        ));
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
