import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ThermometerGauge extends StatefulWidget {
  final double value;
  final double minValue;
  final double maxValue;

  const ThermometerGauge({
    Key? key,
    required this.value,
    this.minValue = 30,
    this.maxValue = 50,
  }) : super(key: key);

  @override
  _ThermometerGaugeState createState() => _ThermometerGaugeState();
}

class _ThermometerGaugeState extends State<ThermometerGauge> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: 300,
            width: 100,
            child: SfLinearGauge(
              minimum: 35,
              maximum: 40,
              orientation: LinearGaugeOrientation.vertical,
              axisTrackStyle: const LinearAxisTrackStyle(
                color: Colors.grey,
                edgeStyle: LinearEdgeStyle.bothCurve,
                thickness: 1.0,
                borderColor: Colors.grey,
              ),
              markerPointers: [
                LinearShapePointer(
                  value: widget.value,
                  shapeType: LinearShapePointerType.invertedTriangle,
                  borderWidth: 1,
                  markerAlignment: LinearMarkerAlignment.end,
                  color: Colors.black,
                ),
              ],

              // barPointers: [
              //   const LinearBarPointer(
              //     value: 35.1,
              //     thickness: 30,
              //     color: Colors.red,
              //     edgeStyle: LinearEdgeStyle.bothCurve,
              //   ),
              // ],
              ranges: const <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: 35,
                  endValue: 35.5,
                  startWidth: 10,
                  endWidth: 10,
                  color: Colors.red,
                ),
                LinearGaugeRange(
                  startValue: 35.5,
                  endValue: 40.5,
                  startWidth: 10,
                  endWidth: 10,
                  color: Colors.orange,
                ),
                LinearGaugeRange(
                  startValue: 36.5,
                  endValue: 37.5,
                  startWidth: 10,
                  endWidth: 10,
                  color: Colors.green,
                ),
                LinearGaugeRange(
                  startValue: 37.5,
                  endValue: 40.5,
                  startWidth: 10,
                  endWidth: 10,
                  color: Colors.orange,
                ),
                LinearGaugeRange(
                  startValue: 39,
                  endValue: 40,
                  startWidth: 10,
                  endWidth: 10,
                  color: Colors.red,
                ),
              ],
              // annotations: [
              //   LinearGaugeAnnotation(
              //     widget: Text(
              //       widget.value.toStringAsFixed(1),
              //       style: TextStyle(
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.black,
              //       ),
              //     ),
              //     position: LinearElementPosition.cross,
              //     axisValue: widget.value,
              //     color: Colors.transparent,
              //   ),
              // ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("${widget.value} C"),
                Text("Body Temperature"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
