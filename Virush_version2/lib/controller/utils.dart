import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    backgroundColor: Colors.blueGrey[700],
    content: Text(
      message,
      style: const TextStyle(
        fontFamily: 'Tinos-Bold',
      ),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
