import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HeartRateIndicator extends StatelessWidget {
  final int heartRate;

  const HeartRateIndicator({required this.heartRate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          child: SfRadialGauge(
            enableLoadingAnimation: true,
            animationDuration: 2000,
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 20,
                maximum: 120,
                ranges: <GaugeRange>[
                  GaugeRange(startValue: 20, endValue: 40, color: Color.fromRGBO(229, 127, 132, 1.0)),
                  GaugeRange(
                      startValue: 40, endValue: 60, color: Color.fromRGBO(242, 181, 60, 1.0)),
                  GaugeRange(startValue: 60, endValue: 90, color: Color.fromRGBO(65 , 161, 145, 1.0)),
                  GaugeRange(
                      startValue: 90, endValue: 100, color: Color.fromRGBO(242, 181, 60, 1.0)),
                  GaugeRange(startValue: 100, endValue: 120, color: Color.fromRGBO(229, 127, 132, 1.0)),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    needleLength: 0.7,
                    needleEndWidth: 5,
                    value: heartRate.toDouble(),
                    enableAnimation: true,
                    animationDuration: 1000,
                    needleColor: const Color.fromRGBO(47, 80, 97, 1.0),
                    animationType: AnimationType.ease,
                  )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        Text("${heartRate} bpm",
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color.fromRGBO(47, 80, 97, 1.0),
            )),
        const Text("Heart Rate", style: TextStyle(fontSize: 17, color: Color.fromRGBO(47, 80, 97, 1.0),),),
      ],
    );
  }
}

// class HeartRateIndicator extends StatelessWidget {
//   final int heartRate;
//
//   const HeartRateIndicator({Key? key, required this.heartRate})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     double percentage = heartRate / 120;
//
//     Color color;
//     if (heartRate >= 90) {
//       color = Colors.red;
//     } else if (heartRate <= 60) {
//       color = Colors.yellow;
//     } else {
//       color = Colors.green;
//     }
//
//     return CircularPercentIndicator(
//       radius: 50,
//       lineWidth: 10,
//       percent: percentage > 1 ? 1 : percentage,
//       center: RotatedBox(
//         quarterTurns: 1,
//         child: Icon(
//           Icons.arrow_right_alt,
//           color: color,
//           size: 30,
//         ),
//       ),
//       circularStrokeCap: CircularStrokeCap.round,
//       backgroundColor: Colors.grey.shade300,
//       progressColor: color,
//       animationDuration: 1000,
//       animateFromLastPercent: true,
//     );
//   }
// }
