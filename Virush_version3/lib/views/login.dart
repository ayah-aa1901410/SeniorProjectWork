import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup.dart';
import '../navbar/navbar.dart';
import '../controller/navbar_controller.dart';
import '../controller/login_controller.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final loginController = Get.put(LoginController());
  final navbarController = Get.put(NavBarController());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isHidden = true;

  void _toggleVisibility() {
    setState(
      () {
        _isHidden = !_isHidden;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                Text(
                  "Keep working on your health",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.red[100],
                  ),
                ),
                //Text Fields
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EAE6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      //email container
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.blueGrey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        //email
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.red.shade400,
                          style: const TextStyle(color: Colors.blueGrey),
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
                      //password container
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        //password
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _isHidden,
                          cursorColor: Colors.red.shade400,
                          style: const TextStyle(color: Colors.blueGrey),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle:
                                TextStyle(color: Colors.blueGrey.shade200),
                            prefixIcon: Icon(Icons.password,
                                color: Colors.blueGrey.shade600),
                            suffixIcon: IconButton(
                              icon: Icon(_isHidden
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
                //Log in button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    // backgroundColor: Colors.red.shade200,
                    fixedSize: const Size(110, 50),
                    backgroundColor: Color.fromRGBO(229, 127, 132, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      // side: BorderSide(
                      //     color: Colors.blueGrey.shade700, width: 2.0),
                    ),
                  ),
                  onPressed: () async {
                    final navigator =
                        Navigator.of(context); // store the Navigator
                    navbarController.changeTabIndex(1);
                    User? user = await loginController.loginUsingEmailPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                        context: context);
                    if (user != null) {
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const NavBar(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                      // color: Colors.blueGrey[700],
                      color: Color(0xFFFFFFFF)
                    ),
                  ),
                ),
                //New user to sign up
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'New user?',
                        style: TextStyle(fontSize: 18, color: Colors.red[100]),
                      ),
                      TextButton(
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                              fontSize: 18, color: Colors.blueGrey[100]),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Signup(),
                            ),
                          );
                        },
                      ),
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
