import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'spo2Chart.dart';
import 'login.dart';
import '../routes/routes.dart';

class Splash extends StatefulWidget {

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 2),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            GetMaterialApp(
              initialRoute: AppPage.getsplash(),
            );
            return  Login();
            // return const SpO2Indicator(
            //   spo2Level: 80,
            // );
          },
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 70.0,
                backgroundImage: AssetImage('assets/images/logo.png'),
                backgroundColor: Color(0xFFF4EAE6),
              ),
              const Text(
                "Virush",
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 40.0,
                  color: Color(0xFFF4EAE6),
                  letterSpacing: 3,
                ),
              ),
              Text("Keep working on your health",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.red[100],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
