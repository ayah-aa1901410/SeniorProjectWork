import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_firestore/Login.dart';

const List<String> list = <String>['Male', 'Female'];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  late final User _user;
  late final DocumentReference<Map<String, dynamic>> _userRef;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isEditing = false;
//done
  @override
  void initState() {
    super.initState();
    _user = auth.currentUser!;
    _userRef = FirebaseFirestore.instance.collection('users').doc(_user.uid);
    _genderController.text = 'Female';
    // print("User id" + _user.uid);
    // print("userRef");
    // print(_userRef);
    // Load user data into text fields
    _loadUserData();
  }

//done
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _userRef.get();
    final Map<String, dynamic> userData = userSnapshot.data()!;
    _nameController.text = userData['fullname'];
    _ageController.text = userData['age'].toString();
    _emailController.text = _user.email!;
    _genderController.text = userData['gender'];
    //_gender = userData['gender'];
    _usernameController.text = userData['username'];
  }

  Future<void> _saveUserData() async {
    await _userRef.set({
      'fullname': _nameController.text,
      'age': int.parse(_ageController.text),
      'gender': _genderController.text,
      'username': _usernameController.text,
    }, SetOptions(merge: true));
  }

  //done
  void _signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                //Navigator.pushReplacementNamed(context, '/login');
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const LoginScreen()));
              },
            ),
          ],
        );
      },
    );
  }

//done
  Future<bool?> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        //#signout
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut(context);
            },
            // onPressed: () async {
            //   await auth.signOut();
            //   auth.authStateChanges().listen((User? user) {
            //     if (user == null) {
            //       print('User is currently signed out!');
            //     } else {
            //       print('User is signed in!');
            //     }
            //   });
            //   //Navigator.of(context).popUntil((route) => route.isFirst);
            //   Navigator.of(context).pushReplacement(
            //       MaterialPageRoute(builder: (context) => const LoginScreen()));
            //   //Navigator.popUntil(context, ModalRoute.withName('/login')); //push rep named
            // },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 25.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),

            const SizedBox(height: 16.0),
            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Gender",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  DropdownButton(
                    items: list
                        .map((String item) => DropdownMenuItem<String>(
                            child: Text(item), value: item))
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _genderController.text = value!;
                      });
                    },
                    value: _genderController.text,
                  ),
                  const Text(""),
                ],
              )
            else
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
              ),
            const SizedBox(height: 32.0),
            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Save changes
                  ElevatedButton.icon(
                    onPressed: () {
                      _saveUserData();
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                  ElevatedButton.icon(
                    //cancel
                    onPressed: () {
                      _loadUserData();
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            //// ElevatedButton(
            // //   onPressed: _saveUserData,
            // //   child: const Text('Save'),
            // // ),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     setState(() {
            //       if (_isEditing) {
            //         _saveUserData();
            //       }
            //       _isEditing = !_isEditing;
            //     });
            //     // onPressed action goes here
            //   },
            //   icon: Icon(
            //       _isEditing ? Icons.save : Icons.edit), //Icon(Icons.edit),
            //   label: _isEditing ? Text('Save changes') : Text('Edit'),
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.blue,
            //     textStyle: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //     ),
            //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //   ),
            // ),

            //delete button
            const SizedBox(height: 150),
            Container(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // show confirmation dialog
                  bool? confirm = await _showConfirmationDialog();
                  if (confirm! || false) {
                    //checkkkkkkkkkkkkkkkkk
                    try {
                      // delete user from Firebase Authentication
                      User? user = auth.currentUser;
                      await user!.delete();

                      // delete user document from Firestore
                      // String userId = user.uid;
                      // await FirebaseFirestore.instance
                      //     .collection('users')
                      //     .doc(userId)
                      //     .delete();

                      // navigate to login screen
                      //Navigator.pushReplacementNamed(context, '/login');
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                    } catch (e) {
                      // show error dialog
                      _showErrorDialog(
                          'Failed to delete account. Please try again later.');
                      //print(e.toString());
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Container(
      //   height: 40,
      //   margin: const EdgeInsets.all(15),
      //   child: ElevatedButton.icon(
      //     onPressed: () async {
      //       // show confirmation dialog
      //       bool? confirm = await _showConfirmationDialog();
      //       if (confirm! || false) {
      //         //checkkkkkkkkkkkkkkkkk
      //         try {
      //           // delete user from Firebase Authentication
      //           User? user = auth.currentUser;
      //           await user!.delete();
      //
      //           // delete user document from Firestore
      //           // String userId = user.uid;
      //           // await FirebaseFirestore.instance
      //           //     .collection('users')
      //           //     .doc(userId)
      //           //     .delete();
      //
      //           // navigate to login screen
      //           //Navigator.pushReplacementNamed(context, '/login');
      //           Navigator.of(context).pushReplacement(MaterialPageRoute(
      //               builder: (context) => const LoginScreen()));
      //         } catch (e) {
      //           // show error dialog
      //           _showErrorDialog(
      //               'Failed to delete account. Please try again later.');
      //           //print(e.toString());
      //         }
      //       }
      //     },
      //     icon: Icon(Icons.delete),
      //     label: Text('Delete Account'),
      //     style: ElevatedButton.styleFrom(
      //       primary: Colors.red,
      //     ),
      //   ),
      // ),
    );
  }
}
