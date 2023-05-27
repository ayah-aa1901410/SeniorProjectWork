//show Snack bar
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

// ScaffoldMessenger.of(context).showSnackBar(
//   const SnackBar(
//     content: Text('Please enter email & password'),
//     duration: Duration(seconds: 3),
//     backgroundColor: Colors.blue,
//   ),
// )
}
