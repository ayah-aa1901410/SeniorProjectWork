import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_firestore/profileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: const Text("You logged in successfully"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.red.shade200,
            fixedSize: const Size(110, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
            ),
          ),
          onPressed: () async {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()));
          },
          child: Text(
            "Go to profile",
            style: TextStyle(
              //fontFamily: 'Caveat',
              fontSize: 20.0,
              color: Colors.blueGrey[700],
            ),
          ),
        ),
      ],
    );
  }
}
