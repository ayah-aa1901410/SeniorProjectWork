import 'dart:async';

import 'package:get/get.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';


class SensorData {
  final String sensorName;
  final String data;

  SensorData(this.sensorName, this.data);
}

class HealthDataController extends GetxController {
  List<SensorData> sensorDataList = [];
  List<SensorData> heartRateDataList = [];
  List<SensorData> bodyTemperatureDataList = [];
  List<SensorData> spO2DataList = [];

  Completer<List<SensorData>> completer = Completer();

  Future<List<SensorData>> getHealthData() async{
      if (!(await NfcManager.instance.isAvailable())) {
        // NFC is not available on this deviceawait NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        return [SensorData('Heart Rate', '-1'), SensorData('Body Temperature', '-1'),SensorData('SpO2', '-1'),];  // get the current timestamp
      }
      try {
        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
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

            // Add the parsed data to the sensorDataList
            sensorDataList.add(heartRateData);
            sensorDataList.add(bodyTemperatureData);
            sensorDataList.add(spO2Data);

            NfcManager.instance.stopSession();

            completer.complete(sensorDataList);

          });
        return completer.future;
      }catch(e) {
        print(e);
        return [SensorData('Heart Rate', '-1'), SensorData('Body Temperature', '-1'),SensorData('SpO2', '-1'),];  // get the current timestamp
      }
  }
}