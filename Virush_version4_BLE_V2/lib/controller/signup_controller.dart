// import 'package:your_app/models/user.dart';
//
// class SignUpController {
//   final User _userModel = User();
//
//   Future<void> signUp(String email, String password, String fullName, String gender, String dateofBirth) async {
//     final result = await _userModel.addUser(email, password, fullName, gender, dateofBirth);
//     if (result == 'Success') {
//       print('User created successfully!');
//     } else {
//       print('Error creating user: $result');
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../view/login.dart';

class SignupController extends GetxController {
  bool isStrongPassword(String password) {
    // Check if password is at least 8 characters long and includes at least one
    // digit, lowercase letter, uppercase letter, and special character
    RegExp regExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return regExp.hasMatch(password);
  }

  bool isValidAge(int age) {
    if (age < 18) {
      return false;
    } else {
      return true;
    }
  }

  int getAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  void submitForm(
    BuildContext context,
    String email,
    String username,
    String password,
    String confirmPassword,
    String gender,
    String fullName,
    DateTime dateofBirth,
  ) async {
    // final form = formKey.currentState;
    // // if (form!.validate()) {
    // //   form.save();
    // //   if (password != confirmPassword) {
    // //     _showErrorDialog(context, 'Passwords do not match.');
    // //     return;
    // //   }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': username,
        'email': email,
        'uid': userId,
        'gender': gender,
        'fullname': fullName,
        'dob': dateofBirth,
      });

      final user = FirebaseAuth.instance.currentUser;
      await user!.updateDisplayName(username);
      showInformationDialog(context,
          "New account was successfully created. You will be directed to Log in page.");
      //Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorDialog(context, 'The password provided is too weak.');
      } else if (e.code == "invalid-email") {
        showErrorDialog(context, "Invalid email");
      } else if (e.code == 'email-already-in-use') {
        showErrorDialog(context, 'The account already exists for that email.');
      } else {
        showErrorDialog(
            context, 'Something went wrong. Please try again later.');
      }
    } catch (e) {
      showErrorDialog(context, 'Something went wrong. Please try again later.');
    }
    //}
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[50],
          title: Container(
            padding: EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: const Text(
              "Error",
              style: TextStyle(
                color: Color(0xFFF4EAE6),
              ),
            ),
          ),
          titlePadding: const EdgeInsets.all(0),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.red.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
              ),
              child: const Text("Accept"),
            )
          ],
        );
      },
    );
  }

  void showInformationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[50],
          title: Container(
            padding: EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: const Text(
              "New account created!",
              style: TextStyle(
                color: Color(0xFFF4EAE6),
              ),
            ),
          ),
          titlePadding: const EdgeInsets.all(0),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              color: Colors.red.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
              ),
              child: const Text("Ok"),
            )
          ],
        );
      },
    );
  }
}
