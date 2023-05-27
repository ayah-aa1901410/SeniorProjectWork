import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String uid;
  final String email;
  final String username;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;

  User({
    required this.uid,
    required this.email,
    required this.username,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
  });

  //factory
  static User fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      //uid: data['uid'] ?? '',
      gender: data['gender'] ?? '',
      fullName: data['fullname'] ?? '',
      dateOfBirth: (data['dob'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'uid': uid,
      'gender': gender,
      'fullname': fullName,
      'dob': dateOfBirth,
    };
  }

  // Register a new user with Firebase Authentication and create a user document in Firestore
  static Future<String?> registerWithEmailAndPassword(
      String email,
      String password,
      String username,
      String fullname,
      String gender,
      DateTime dob) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = User(
        uid: result.user!.uid,
        username: username,
        email: email,
        gender: gender,
        fullName: fullname,
        dateOfBirth: dob,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
      return 'Success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign in with email and password
  static Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign out the current user
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Retrieve a user from the Firestore database
  static Future<User?> getUser(String userId) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    } else {
      return null;
    }
  }

  // Update the current user's profile information
  static Future<String?> updateUserProfile(
      String username, String fullname, String gender, DateTime dob) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      User user = User(
        uid: uid,
        username: username,
        email: FirebaseAuth.instance.currentUser!.email!,
        gender: gender,
        fullName: fullname,
        dateOfBirth: dob,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(user.toMap());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // associated data from Firebase Authentication and Firestore
  static Future<String?> deleteAccount() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await FirebaseAuth.instance.currentUser!.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
// Future<void> addUser(User user) async {
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(user.uid)
//       .set(user.toMap());
// }
//
// Future<User?> getUser(String userId) async {
//   DocumentSnapshot doc =
//       await FirebaseFirestore.instance.collection('users').doc(userId).get();
//   if (doc.exists) {
//     return User.fromFirestore(doc);
//   } else {
//     return null;
//   }
// }
//
// // Change the current user's password
// static Future<String?> changePassword(String newPassword) async {
// try {
// await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
// return null;
// } on FirebaseAuthException catch (e) {
// return e.message;
// }
// }
