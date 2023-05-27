import 'package:ble_data_converter/ble_data_converter/src/ble_data_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name == "ESP32") {
      return Column(
        children: <Widget>[
          Text(
            result.device.name,
          ),
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      trailing: ElevatedButton(
        child: const Text('CONNECT'),
        onPressed: (result.advertisementData.connectable) ? onTap : null,
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
        } else if (title == 'heart rate' && value!=null && value.isNotEmpty) {
          heartRateValue = BLEDataConverter.i32.bytesToInt(value!);
          value1 = heartRateValue;
        } else if (title == 'sp02' && value!=null && value.isNotEmpty) {
          spO2Value = BLEDataConverter.i32.bytesToInt(value!);
          value1 = spO2Value;
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
