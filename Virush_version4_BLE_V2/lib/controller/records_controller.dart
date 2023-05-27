import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class RecordsController extends GetxController {
  String getDateTime(Timestamp timestamp) {
    // Convert timestamp to DateTime object
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

// Format DateTime object to string
    String formattedDateTime = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

    return formattedDateTime;
  }

  Stream<QuerySnapshot> getUserRecords(String uid) {
    return FirebaseFirestore.instance
        .collection('records')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  // TextStyle getStyledText(String input) {
  //   switch (input) {
  //     case 'healthy':
  //       return const TextStyle(
  //           fontSize: 20,
  //           fontFamily: 'Tinos-Bold',
  //           color: Colors.black,
  //           backgroundColor: Colors.green);
  //     case 'symptomatic':
  //       return TextStyle(
  //           fontFamily: 'Tinos-Bold',
  //           backgroundColor: Colors.yellow[500],
  //           color: Colors.black);
  //     case 'covid19':
  //       return const TextStyle(
  //           fontFamily: 'Tinos-Bold',
  //           color: Colors.black,
  //           backgroundColor: Colors.red);
  //     default:
  //       return const TextStyle();
  //   }
  // }

  TextSpan getStyledText(String input) {
    switch (input) {
      case 'healthy':
        return const TextSpan(
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'Tinos-Bold',
              color: Color.fromRGBO(65 , 161, 145, 1.0),
              // backgroundColor: Colors.green
          ),
          text: "Healthy",
        );
      case 'symptomatic':
        return TextSpan(
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Tinos-Bold',
            color: Colors.yellow[700],
            // backgroundColor: Colors.green
          ),
          text: "Symptomatic",
        );
      case 'covid19':
        return const TextSpan(
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Tinos-Bold',
            color: Color.fromRGBO(229, 127, 132, 1.0),
            // backgroundColor: Colors.green
          ),
          text: "COVID-19",
        );
      default:
        return const TextSpan();
    }
  }
}
