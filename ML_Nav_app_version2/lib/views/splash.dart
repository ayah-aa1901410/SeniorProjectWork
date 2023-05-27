import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nav_app/views/login.dart';
import '../navbar/navbar.dart';
import '../routes/routes.dart';
import 'home.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              GetMaterialApp(
                initialRoute: AppPage.getsplash(),
              );
              return const Login();
              //return const NavBar();
            })));

    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70.0,
                backgroundImage: AssetImage('assets/images/logo.png'),
                backgroundColor: Colors.yellow[50],
              ),
              Text(
                "Virush",
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 40.0,
                  color: Colors.yellow[50],
                  //fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              Text("Keep working on your health",
                  style: TextStyle(
                    //fontFamily: 'Caveat',
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
