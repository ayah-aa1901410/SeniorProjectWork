import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_firestore/utlis.dart';
import 'Login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  Future<void> signUpFire(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, 'The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showSnackBar(context, 'The email address is not valid.');
      } else {
        showSnackBar(context, 'Error message: ${e.message}');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      print(e);
    }
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _ishidden = true;

  void _toggleVisibility() {
    setState(
      () {
        _ishidden = !_ishidden;
      },
    );
  }

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
              // CircleAvatar(
              //   radius: 70.0,
              //   backgroundImage: AssetImage('assets/images/logo.png'),
              //   backgroundColor: Colors.yellow[50],
              // ),
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
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                          hintText: "Full Name",
                          hintStyle: TextStyle(color: Colors.blueGrey.shade200),
                        ),
                      ),
                    ),
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
                        controller: _emailController,
                        cursorColor: Colors.red.shade400,
                        style: TextStyle(color: Colors.blueGrey),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.blueGrey.shade200),
                        ),
                      ),
                    ),
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
                          hintText: "Username",
                          hintStyle: TextStyle(color: Colors.blueGrey.shade200),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Container(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _ishidden ? true : false,
                          cursorColor: Colors.red.shade400,
                          style: TextStyle(color: Colors.blueGrey),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(_ishidden
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              color: Colors.blueGrey[600],
                              onPressed: _toggleVisibility,
                            ),
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(
                              color: Colors.blueGrey.shade200,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                  signUpFire(_emailController.text, _passwordController.text);
                  /////////////////Maybe u need to change this
                  Navigator.of(context).pushReplacement(CupertinoPageRoute(
                      builder: (context) => const LoginScreen()));
                },
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    //fontFamily: 'Caveat',
                    fontSize: 20.0,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
