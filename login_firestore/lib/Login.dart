import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_firestore/signup.dart';
import 'package:login_firestore/utlis.dart';

import 'homeScreen.dart';
import 'newSignUp.dart';
import 'profileScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  //Login function
  static Future<User?> loginUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    if (password.isEmpty || email.isEmpty) {
      showSnackBar(context, "Please enter email & password");
    } else {
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == "invalid-email") {
          showSnackBar(context, "Invalid email");
        } else if (e.code == "user-not-found") {
          showSnackBar(context, "No user found for that email");
        } else if (e.code == 'wrong-password') {
          showSnackBar(context, "Incorrect password. Please try again.");
        } else if (e.code == 'too-many-requests') {
          showSnackBar(
              context, "Too many sign-in attempts. Please try again later.");
        }
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: SingleChildScrollView(
        // added this
        child: SafeArea(
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
                ////////////////////////
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
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
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.red.shade400,
                          style: TextStyle(color: Colors.blueGrey),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle:
                                TextStyle(color: Colors.blueGrey.shade200),
                            prefixIcon: Icon(Icons.mail,
                                color: Colors.blueGrey.shade600),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _ishidden ? true : false,
                          cursorColor: Colors.red.shade400,
                          style: TextStyle(color: Colors.blueGrey),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle:
                                TextStyle(color: Colors.blueGrey.shade200),
                            prefixIcon: Icon(Icons.password,
                                color: Colors.blueGrey.shade600),
                            suffixIcon: IconButton(
                              icon: Icon(_ishidden
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              color: Colors.blueGrey[600],
                              onPressed: _toggleVisibility,
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
                      side: BorderSide(
                          color: Colors.blueGrey.shade700, width: 2.0),
                    ),
                  ),
                  onPressed: () async {
                    User? user = await loginUsingEmailPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                        context: context);
                    print(user);
                    if (user != null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                    }
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
                              builder: (context) =>
                                  NewSignupPage())); // was sign up!!!!!!
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
