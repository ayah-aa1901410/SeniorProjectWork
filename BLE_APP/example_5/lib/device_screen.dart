import 'dart:async';

import 'package:ble_data_converter/ble_data_converter/src/ble_data_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  DeviceScreen({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  // flutterBlue
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  String stateText = 'Connecting';
  String connectButtonText = 'Disconnect';

  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  List<BluetoothService> bluetoothService = [];
  Map<String, List<int>> notifyDatas = {};

  @override
  initState() {
    super.initState();
    setBleConnectionState(deviceState);

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
    setState(() {});
  }


  Future<bool> connect() async {
    Future<bool>? returnValue;
    setState(() {
      stateText = 'Connecting';
    });

    await widget.device
        .connect(autoConnect: false)
        .timeout(Duration(milliseconds: 15000), onTimeout: () {

      returnValue = Future.value(false);
      debugPrint('timeout failed');


      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) async {
      bluetoothService.clear();
      if (returnValue == null) {

        debugPrint('connection successful');
        print('start discover service');
        List<BluetoothService> bleServices =
            await widget.device.discoverServices();
        setState(() {
          bluetoothService = bleServices;
        });

        for (BluetoothService service in bleServices) {
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

  void disconnect() {
    try {
      setState(() {
        stateText = 'Disconnecting';
      });
      widget.device.disconnect();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(widget.device.name),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('$stateText'),
              OutlinedButton(
                  onPressed: () {
                    if (deviceState == BluetoothDeviceState.connected) {
                      disconnect();
                      deviceState = BluetoothDeviceState.disconnected;
                    } else if (deviceState == BluetoothDeviceState.disconnected) {
                      connect();
                      deviceState = BluetoothDeviceState.connected;
                    }
                  },
                  child: Text(connectButtonText)),
            ],
          ),

          Expanded(
            child: ListView.separated(
              itemCount: bluetoothService.length,
              itemBuilder: (context, index) {
                return listItem(bluetoothService[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            ),
          ),
        ],
      )),
    );
  }


  Widget characteristicInfo(BluetoothService r) {
    String name1 = '';
    String name2 = '';
    String name3 = '';
    String data = '';

    for (BluetoothCharacteristic c in r.characteristics) {
      if(c.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
        data = '';
        name1 += '\t\tTemperature: ';

        if (notifyDatas[c.uuid.toString()] != null && notifyDatas[c.uuid.toString()]!.isNotEmpty) {
          data = notifyDatas[c.uuid.toString()].toString();
          name1 += '\t\t\t\t$data\n';
        }

      }
      if(c.uuid.toString() == "860a3d66-eb23-11ed-a05b-0242ac120003"){
        data = '';
        name2 += '\t\tPulse: ';

        if (notifyDatas[c.uuid.toString()] != null && notifyDatas[c.uuid.toString()]!.isNotEmpty) {
          data = notifyDatas[c.uuid.toString()].toString();
          name2 += '\t\t\t\t$data\n';
        }

      }

      if(c.uuid.toString() == "97cba7a6-eb23-11ed-a05b-0242ac120003" ){
          data = '';
          name3 += '\t\tSp02: ';

          if (notifyDatas[c.uuid.toString()] != null && notifyDatas[c.uuid.toString()]!.isNotEmpty) {
            data = notifyDatas[c.uuid.toString()].toString();
            name3 += '\t\t\t\t$data\n';
          }

      }
    }
    return Text(name1 + name2 + name3);
  }

  Widget listItem(BluetoothService r) {
    return ListTile(
      onTap: null,
      subtitle: characteristicInfo(r),
    );
  }
}
