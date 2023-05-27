import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'utils.dart';

class LoginController extends GetxController {
  //Login function
  Future<User?> loginUsingEmailPassword(
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
          showSnackBar(
              context, "Invalid email. Please enter a valid email address.");
        } else if (e.code == "user-not-found") {
          showSnackBar(context, "No user found for that email");
        } else if (e.code == 'wrong-password') {
          showSnackBar(context, "Incorrect password. Please try again.");
        } else if (e.code == 'too-many-requests') {
          showSnackBar(
              context, "Too many sign-in attempts. Please try again later.");
        } else if (e.code == 'network-request-failed') {
          showSnackBar(context,
              "No WI-FI connection. Check your connection and try again.");
        } else {
          showSnackBar(context, "Error occurred. Please try again.");
        }
      }
    }
    return user;
  }



  // void _toggleVisibility() {
  //   setState(
  //         () {
  //       _ishidden = !_ishidden;
  //     },
  //   );
  // }

}
