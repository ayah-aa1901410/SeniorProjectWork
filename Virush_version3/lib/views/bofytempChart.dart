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
                  borderColor: const Color.fromRGBO(47, 80, 97, 1.0),
                  markerAlignment: LinearMarkerAlignment.end,
                  // color: Colors.black,
                  color: const Color.fromRGBO(47, 80, 97, 1.0),
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
                  color: Color.fromRGBO(229, 127, 132, 1.0),
                ),
                LinearGaugeRange(
                  startValue: 35.5,
                  endValue: 40.5,
                  startWidth: 10,
                  endWidth: 10,
                  color: Color.fromRGBO(242, 181, 60, 1.0),
                ),
                LinearGaugeRange(
                  startValue: 36.5,
                  endValue: 37.5,
                  startWidth: 10,
                  endWidth: 10,
                  color: Color.fromRGBO(65 , 161, 145, 1.0),
                ),
                LinearGaugeRange(
                  startValue: 37.5,
                  endValue: 40.5,
                  startWidth: 10,
                  endWidth: 10,
                  color: Color.fromRGBO(242, 181, 60, 1.0),
                ),
                LinearGaugeRange(
                  startValue: 39,
                  endValue: 40,
                  startWidth: 10,
                  endWidth: 10,
                  color: Color.fromRGBO(229, 127, 132, 1.0),
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
                const SizedBox(height: 10,),
                Text("${widget.value} C", style: const TextStyle(fontSize: 17,  color: Color.fromRGBO(47, 80, 97, 1.0),),),
                const Text("Body Temperature", style: TextStyle(fontSize: 17,  color: Color.fromRGBO(47, 80, 97, 1.0),),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
