import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/records_controller.dart';

class Records extends StatefulWidget {
  const Records({Key? key}) : super(key: key);

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  final recordsController = Get.put(RecordsController());
  FirebaseAuth auth = FirebaseAuth.instance;
  late final User _user;

  @override
  void initState() {
    super.initState();
    _user = auth.currentUser!;
  }

  //For testing purposes
  Future<void> addRecord() async {
    final CollectionReference recordsRef =
        FirebaseFirestore.instance.collection('records');

    // Generate three random values with specified ranges
    final Random random = Random();
    final int randomInt1 = random.nextInt(31) + 60; // value1 between 60 and 90
    final double randomDouble2 = (random.nextDouble() * (39 - 36.5)) +
        36.5; // value2 between 36.5 and 39
    final randDouble = double.parse(randomDouble2.toStringAsFixed(2));
    final int randomInt3 = random.nextInt(11) + 90; // value3 between 90 and 100

    // Create a new document with the three random values and additional fields
    final Map<String, dynamic> data = <String, dynamic>{
      'uid': _user.uid,
      'heart_rate': randomInt1,
      'body_temperature': randDouble,
      'spo2': randomInt3,
      'current_date_time': DateTime.now(),
      'cough_sound_result': 'healthy',
      'stat_ml_result': 'healthy',
      'overall_health': 'healthy',
    };

    // Add the new document to the 'records' collection
    await recordsRef.add(data);
  }

  //For testing purposes
  Future<void> addMultipleRecords(int count) async {
    for (int i = 0; i < count; i++) {
      await addRecord();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EAE6),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: recordsController.getUserRecords(_user.uid),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data?.size == 0) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.find_in_page_rounded,
                        size: 70,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No records found',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your health records will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      ),
                      //For testing
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            addMultipleRecords(1);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Records'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text("My Health Records:",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.red[400],
                          )),
                    ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          addMultipleRecords(1);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Records'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListView(
                        children: snapshot.data!.docs.map(
                          (DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            return RecordCard(data: data);
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  final recordsController = Get.put(RecordsController());

  final Map<String, dynamic> data;

  RecordCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      color: Colors.blueGrey[100],
      child: Column(
        children: [
          //Date/time and health status
          ListTile(
            title: Text(
              'Date and Time: ${recordsController.getDateTime(data['current_date_time'])}',
              style: const TextStyle(color: Colors.teal),
            ),
            //Replace it with a row for color specific word
            subtitle: RichText(
              text: TextSpan(
                text: 'Health Status: ',
                style: const TextStyle(
                  fontFamily: 'Tinos-Bold',
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  recordsController.getStyledText(data['overall_health']),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //spo2
                Row(
                  children: [
                    const SizedBox(width: 25),
                    const Image(
                      image: AssetImage('assets/images/spo2_icon.png'),
                      width: 25.0,
                      height: 25.0,
                    ),
                    const SizedBox(width: 10),
                    Text('SPO2: ${data['spo2']}'),
                  ],
                ),
                //heart
                Row(
                  children: [
                    const SizedBox(width: 20),
                    const Image(
                      image: AssetImage('assets/images/heartrate_icon.png'),
                      width: 30.0,
                      height: 30.0,
                    ),
                    const SizedBox(width: 10),
                    Text('Heart Rate: ${data['heart_rate']}'),
                  ],
                ),
                //body temp
                Row(
                  children: [
                    const SizedBox(width: 20),
                    const Image(
                      image: AssetImage('assets/images/bodytemp_icon.png'),
                      width: 30.0,
                      height: 30.0,
                    ),
                    const SizedBox(width: 10),
                    Text('Body Temperature: ${data['body_temperature']}'),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const SizedBox(width: 25),
                    const FaIcon(
                      FontAwesomeIcons.kitMedical,
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        text: 'Vital Signs Status: ',
                        style: const TextStyle(
                          fontFamily: 'Tinos-Bold',
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          recordsController
                              .getStyledText(data['stat_ml_result']),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 25),
                    const FaIcon(
                      FontAwesomeIcons.headSideCough,
                      size: 20,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        text: 'Cough Sound Test Result: ',
                        style: const TextStyle(
                          fontFamily: 'Tinos-Bold',
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          recordsController.getStyledText(
                            data['cough_sound_result'],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
