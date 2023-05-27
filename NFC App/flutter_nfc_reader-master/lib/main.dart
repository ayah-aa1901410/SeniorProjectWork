import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}


class SensorData {
  final String sensorName;
  final String data;

  SensorData(this.sensorName, this.data);
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<SensorData> sensorDataList = [];
  List<SensorData> heartRateDataList = [];
  List<SensorData> bodyTemperatureDataList = [];
  List<SensorData> spO2DataList = [];


  @override
  Widget build(BuildContext context) {
    List<SensorData> heartRateDataList = [];
    List<SensorData> bodyTemperatureDataList = [];
    List<SensorData> spO2DataList = [];

    sensorDataList.forEach((data) {
      if (data.sensorName == 'Heart Rate') {
        heartRateDataList.add(data);
      } else if (data.sensorName == 'Body Temperature') {
        bodyTemperatureDataList.add(data);
      } else if (data.sensorName == 'SpO2') {
        spO2DataList.add(data);
      }
    });

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Senior NFC App')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) =>
            ss.data != true
                ? Center(
                child: Text('NfcManager.isAvailable(): ${ss.data}'))
                : Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.vertical,
              children: [
                Flexible(
                  flex: 2,
                  child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        bottom: TabBar(
                          tabs: [
                            Tab(text: 'Heart Rate'),
                            Tab(text: 'Body Temperature'),
                            Tab(text: 'SpO2'),
                          ],
                        ),
                        automaticallyImplyLeading: false,
                      ),
                      body: TabBarView(
                        children: [
                          heartRateDataList.isEmpty
                              ? Center(child: Text('No heart rate data yet.'))
                              : ListView.builder(
                            itemCount: heartRateDataList.length,
                            itemBuilder: (context, index) {
                              final data = heartRateDataList[index];
                              return ListTile(
                                title: Text(data.sensorName),
                                subtitle: Text(data.data),
                              );
                            },
                          ),
                          bodyTemperatureDataList.isEmpty
                              ? Center(child: Text('No body temperature data yet.'))
                              : ListView.builder(
                            itemCount: bodyTemperatureDataList.length,
                            itemBuilder: (context, index) {
                              final data = bodyTemperatureDataList[index];
                              return ListTile(
                                title: Text(data.sensorName),
                                subtitle: Text(data.data),
                              );
                            },
                          ),
                          spO2DataList.isEmpty
                              ? Center(child: Text('No SpO2 data yet.'))
                              : ListView.builder(
                            itemCount: spO2DataList.length,
                            itemBuilder: (context, index) {
                              final data = spO2DataList[index];
                              return ListTile(
                                title: Text(data.sensorName),
                                subtitle: Text(data.data),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: GridView.count(
                    padding: EdgeInsets.all(4),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: [
                      ElevatedButton(
                          child: Text('Tag Read'),
                          onPressed: _tagRead),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all()),
                    child: Center(
                      child: Text(
                        'HEALTHY',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // get the current timestamp
      DateTime now = DateTime.now();
      String formattedTime = '${now.hour}:${now.minute}:${now.second}';

      Uint8List identifier =
      Uint8List.fromList(tag.data["nfca"]['identifier']);
      final String identifier1 = identifier
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join(':');

      final cachedMessage = tag.data["ndef"] != null
          ? tag.data["ndef"]["cachedMessage"] ?? {}
          : {};

      // Parse heart rate data
      final List<int> hrPayload = cachedMessage['records'][0]['payload'];
      final String hrData = utf8.decode(hrPayload).substring(3);
      final heartRateData = SensorData('Heart Rate', hrData);

      // Parse body temperature data
      final List<int> btPayload = cachedMessage['records'][1]['payload'];
      final String btData = utf8.decode(btPayload).substring(3);
      final bodyTemperatureData = SensorData('Body Temperature', btData);

      // Parse SpO2 data
      final List<int> spPayload = cachedMessage['records'][2]['payload'];
      final String spData = utf8.decode(spPayload).substring(3);
      final spO2Data = SensorData('SpO2', spData);

      setState(() {
        // Add the parsed data to the sensorDataList
        sensorDataList.add(heartRateData);
        sensorDataList.add(bodyTemperatureData);
        sensorDataList.add(spO2Data);
      });
      NfcManager.instance.stopSession();
    });
  }
}

