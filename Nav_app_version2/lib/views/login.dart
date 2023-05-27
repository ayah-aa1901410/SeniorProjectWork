import 'package:flutter/material.dart';
import 'package:nav_app/views/passwordField.dart';
import 'package:nav_app/views/signup.dart';

import '../navbar/navbar.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
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
              Text(
                "Keep working on your health",
                style: TextStyle(
                  //fontFamily: 'Caveat',
                  fontSize: 20.0,
                  color: Colors.red[100],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                      child: TextField(
                        cursorColor: Colors.red.shade400,
                        style: TextStyle(color: Colors.blueGrey),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email or Username",
                          hintStyle: TextStyle(color: Colors.blueGrey.shade200),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: PasswordField(),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red.shade200,
                  fixedSize: const Size(110, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side:
                        BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const NavBar()));
                },
                child: Text(
                  "Log in",
                  style: TextStyle(
                    //fontFamily: 'Caveat',
                    fontSize: 20.0,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'New user?',
                      style: TextStyle(fontSize: 15, color: Colors.red[100]),
                    ),
                    TextButton(
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                            fontSize: 20, color: Colors.blueGrey[100]),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Signup()));
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
