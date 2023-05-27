import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virush_version2/views/heartrateChart.dart';
import 'package:virush_version2/views/spo2Chart.dart';
import '/views/takeTest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bofytempChart.dart';

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

  FirebaseAuth auth = FirebaseAuth.instance;
  late final User _user;
  final CollectionReference recordsRef =
      FirebaseFirestore.instance.collection('records');

  TextEditingController spo2 = TextEditingController();
  TextEditingController heartrate = TextEditingController();
  TextEditingController bodytemperature = TextEditingController();
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
        spo2.text = "${latestRecordData['spo2']}";
        heartrate.text = "${latestRecordData['heart_rate']}";
        bodytemperature.text = "${latestRecordData['body_temperature']}";
        userHealth = "${latestRecordData['overall_health']}";
        //print("jgrrrrr");
        setState(() {
          spo2 = spo2;
          heartrate = heartrate;
          bodytemperature = bodytemperature;
          userHealth = userHealth;
        });
      }
      print(latestRecord.data());
    } else {
      spo2.text = "-1";
      heartrate.text = "-1";
      bodytemperature.text = "-1";
      userHealth = "--";
      setState(() {
        spo2 = spo2;
        heartrate = heartrate;
        bodytemperature = bodytemperature;
        userHealth = userHealth;
      });
      print('No records found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EAE6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          vertical: 10,
                          horizontal: 15,
                        ),
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        // color: Colors.blueGrey[100],
                        color: const Color(0xFFFFFFFFF),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Image.asset(
                              //   'assets/images/health_scale.png',
                              //   width: 100,
                              //   height: 60,
                              // ),
                              Column(
                                children: [
                                  const Text(
                                    'Overall Health',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(47, 80, 97, 1.0),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Icon(
                                    Icons.circle,
                                    color: getHealthColor(userHealth),
                                    size: 100,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.water_drop_rounded,
                                          color: Colors.red[300],
                                        size: 35,),
                                      Text("COVID-19", style: TextStyle(color: Color.fromRGBO(47, 80, 97, 1.0),),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.water_drop_rounded,
                                          color: Colors.yellow[700],
                                          // color: Color.fromRGBO(242, 212, 60, 1.0),
                                      size: 35,),
                                      Text("Symptomatic", style: TextStyle(color: Color.fromRGBO(47, 80, 97, 1.0),),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.water_drop_rounded,
                                          color: const Color.fromRGBO(65 , 161, 145, 1.0),
                                        size: 35,),
                                      Text("Healthy", style: TextStyle(color: Color.fromRGBO(47, 80, 97, 1.0),),),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        color: const Color(0xFFFFFFFF),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                          child: Column(
                            children: [
                              const Text(
                                'Vital Signs',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold, color: Color.fromRGBO(47, 80, 97, 1.0),),
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
                                        heartRate: int.parse(heartrate.text),
                                      ),
                                    ],
                                  ),
                                  ThermometerGauge(
                                    value: double.parse(bodytemperature.text),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Image.asset(
                      //   "assets/images/health_overview.PNG",
                      //   width: 350,
                      // ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(229, 127, 132, 1.0),
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
                        child: const Text("Take Test", style: TextStyle(fontWeight: FontWeight.bold,),),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getHealthColor(String userHealth) {
    if (userHealth == "healthy") {
      return const Color.fromRGBO(65 , 161, 145, 1.0);
    } else if (userHealth == "Symptomatic") {
      return Colors.yellow[700];
    } else if (userHealth == "covid-19") {
      return const Color.fromRGBO(229, 127, 132, 1.0);
    } else {
      return Colors.blueGrey[100];
    }
  }
}
