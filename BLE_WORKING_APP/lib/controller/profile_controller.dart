import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/login.dart';

class ProfileController extends GetxController {
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
              "Account was deleted",
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
                    MaterialPageRoute(builder: (context) =>  Login()));
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

  Future<bool?> showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF4EAE6),
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
              "Deleting account!",
              style: TextStyle(
                color: Color(0xFFF4EAE6),
              ),
            ),
          ),
          titlePadding: const EdgeInsets.all(0),
          content: const Text(
              'Are you sure you want to delete your account?\nThis action cannot be undone.', style: TextStyle(fontSize: 17, color: Color.fromRGBO(47, 80, 97, 1.0))),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              color: Colors.blueGrey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                // side: BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
              ),
              child: const Text("Cancel", style: TextStyle(fontSize: 17, color: Color.fromRGBO(47, 80, 97, 1.0)),),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              color: Color.fromRGBO(229, 127, 132, 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                // side: BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ],
        );
      },
    );
  }

  DateTime getDateTime(Timestamp timestamp) {
    // Convert timestamp to DateTime object
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    return dateTime;
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

  void deleteAccount(BuildContext context, User? user) async {
    bool? confirm = await showConfirmationDialog(context);
    if (confirm! || false) {
      try {
        String userId = user!.uid;
        // delete user from Firebase Authentication
        await user.delete();

        // delete user document from users collection

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        //delete all user records from records collection
        WriteBatch batch = FirebaseFirestore.instance.batch();

        await FirebaseFirestore.instance
            .collection('records')
            .where('uid', isEqualTo: userId)
            .get()
            .then((querySnapshot) => {
                  querySnapshot.docs.forEach((document) {
                    batch.delete(document.reference);
                  })
                });
        batch.commit().then((document) {
          debugPrint('User Documents Deleted');
        });
        // navigate to login screen
        //Navigator.pushReplacementNamed(context, '/login');
        showInformationDialog(
            context, "Your account was successfully deleted.");
      } catch (e) {
        // show error dialog
        showErrorDialog(
            context, 'Failed to delete account. Please try again later.');
        //print(e.toString());
      }
    }
  }

  void signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF4EAE6),
          title: Container(
            padding: EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(65 , 161, 145, 1.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: const Text(
              "Confirm logout",
              style: TextStyle(
                color: Color(0xFFF4EAE6),
              ),
            ),
          ),
          titlePadding: const EdgeInsets.all(0),
          content: const Text('Are you sure you want to log out?', style: TextStyle(fontSize: 17, color: Color.fromRGBO(47, 80, 97, 1.0))),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              color: Color.fromRGBO(229, 127, 132, 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                // side: BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
              ),
              child: const Text("No", style: TextStyle(fontSize: 17, color: Colors.white),),
            ),
            MaterialButton(
              onPressed: () async {
                //Navigator.of(context).pop(true);
                await FirebaseAuth.instance.signOut();
                //Navigator.pushReplacementNamed(context, '/login');
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) =>  Login()));
              },
              color: Color.fromRGBO(65 , 161, 145, 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
                // side: BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
              ),
              child: const Text(
                "Yes",
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
