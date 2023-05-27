import 'dart:async';

import 'package:get/get.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:ble_data_converter/ble_data_converter/src/ble_data_converter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SensorData {
  final String sensorName;
  final String data;

  SensorData(this.sensorName, this.data);
}

class BLE_Controller extends GetxController {
  List<SensorData> sensorDataList = [];
  List<SensorData> heartRateDataList = [];
  List<SensorData> bodyTemperatureDataList = [];
  List<SensorData> spO2DataList = [];

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  String stateText = 'Connecting';
  String connectButtonText = 'Disconnect';
  bool _isScanning = false;
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  @override
  void initState() {
    initBle();
    setBleConnectionState(deviceState);
  }

  void initBle() {
    flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
    });
  }

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
  }

  void disconnect() {
    try {
      stateText = 'Disconnecting';
      // widget.device.disconnect();
    } catch (e) {}
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

}