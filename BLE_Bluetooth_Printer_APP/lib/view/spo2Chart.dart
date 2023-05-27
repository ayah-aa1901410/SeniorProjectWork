// import 'package:flutter/material.dart';
// import 'package:percent_indicator/percent_indicator.dart';
//
// class SpO2Indicator extends StatelessWidget {
//   final int spo2Level;
//
//   const SpO2Indicator({Key? key, required this.spo2Level}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Color? color;
//     if (spo2Level >= 94) {
//       color = Colors.green;
//     } else if (spo2Level >= 90) {
//       color = Colors.yellow[700];
//     } else {
//       color = Colors.red;
//     }
//
//     return CircularPercentIndicator(
//       radius: 50.0,
//       lineWidth: 10.0,
//       percent: spo2Level / 100.0,
//       center: Text(
//         '$spo2Level%',
//         style: TextStyle(fontSize: 20.0),
//       ),
//       progressColor: color,
//       circularStrokeCap: CircularStrokeCap.round,
//       backgroundColor: Colors.grey,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

// class SpO2Indicator extends StatelessWidget {
//   final int spo2;
//
//   const SpO2Indicator({required this.spo2});
//
//   @override
//   Widget build(BuildContext context) {
//     ColorTween colorTween = ColorTween(
//       begin: Colors.blue,
//       end: spo2 < 95 ? Colors.red : Colors.green,
//     );
//
//     return TweenAnimationBuilder(
//       tween: colorTween,
//       duration: Duration(milliseconds: 500),
//       builder: (BuildContext context, Color? color, Widget? child) {
//         return Container(
//           width: 200.0,
//           height: 40.0,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20.0),
//             color: color,
//           ),
//           child: LiquidCircularProgressIndicator(
//             value: spo2 / 100,
//             backgroundColor: Colors.white,
//             //valueColor: Colors.yellow,
//             //borderRadius: BorderRadius.circular(20.0),
//             center: Text(
//               '${spo2.toInt()}',
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class SpO2Indicator extends StatelessWidget {
  final int spo2Level;

  SpO2Indicator({required this.spo2Level});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            child: LiquidCircularProgressIndicator(
              value: spo2Level / 120,
              backgroundColor: Colors.grey[300]!,
              borderWidth: 2.0,
              // borderColor: Colors.grey, //_getSpo2Color(spo2Level),
              borderColor: const Color(0xFFBDB6B5),
              valueColor:
                  AlwaysStoppedAnimation<Color>(_getSpo2Color(spo2Level)),
              center: Text(
                '$spo2Level%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            "SpO2",
            style: TextStyle(
              fontSize: 15,
              color: Color.fromRGBO(47, 80, 97, 1.0),
            ),
          )
        ],
      ),
    );
  }

  Color _getSpo2Color(int spo2Level) {
    if (spo2Level >= 95) {
      return Color.fromRGBO(65, 161, 145, 1.0);
    } else if (spo2Level >= 90) {
      return Color.fromRGBO(251, 192, 45, 1.0);
    } else {
      return Color.fromRGBO(229, 127, 132, 1.0);
    }
  }
}
