import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

const List<String> list = <String>['Male', 'Female'];

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final profileController = Get.put(ProfileController());
  FirebaseAuth auth = FirebaseAuth.instance;

  late final User _user;
  late final DocumentReference<Map<String, dynamic>> _userRef;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late DateTime dob;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _user = auth.currentUser!;
    _userRef = FirebaseFirestore.instance.collection('users').doc(_user.uid);
    _genderController.text = 'Female';
    loadUserData();
  }

  Future<void> loadUserData() async {
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _userRef.get();
    final Map<String, dynamic> userData = userSnapshot.data()!;
    _nameController.text = userData['fullname'];
    dob = profileController.getDateTime(userData['dob']);
    _ageController.text = profileController.getAge(dob).toString();
    _emailController.text = _user.email!;
    _genderController.text = userData['gender'];
    _usernameController.text = userData['username'];
  }

  Future<void> saveUserData() async {
    await _userRef.set({
      'fullname': _nameController.text,
      'gender': _genderController.text,
      'username': _usernameController.text,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EAE6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //header column
                        Column(
                          children: [
                            //logout and Fullname
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Fullname
                                Card(
                                  color: Colors.blueGrey[200],
                                  margin: const EdgeInsets.all(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0,
                                      vertical: 7.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.person_rounded,
                                          size: 50,
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            controller: _nameController,
                                            style:
                                                const TextStyle(fontSize: 20),
                                            enabled: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //Logout button
                                ElevatedButton.icon(
                                  label: const Text("Log out"),
                                  icon: const Icon(Icons.logout),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[400],
                                    padding: const EdgeInsets.all(10),
                                  ),
                                  onPressed: () {
                                    profileController.signOut(context);
                                  },
                                ),
                              ],
                            ),
                            //Divider
                            const SizedBox(
                              height: 10.0,
                              width: 380,
                              child: Divider(
                                color: Colors.blueGrey,
                                thickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                        //Data
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 25.0),
                              //email
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.teal),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                enabled: false,
                              ),
                              const SizedBox(height: 16.0),
                              //age
                              TextField(
                                controller: _ageController,
                                decoration: const InputDecoration(
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.teal),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  labelText: 'Age',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                enabled: false,
                              ),
                              const SizedBox(height: 16.0),
                              //Fullname Field
                              TextFormField(
                                controller: _nameController,
                                cursorColor: Colors.teal,
                                decoration: const InputDecoration(
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.teal),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                  ),
                                ),
                                enabled: _isEditing,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _nameController.text = value!;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              //username
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.teal),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  labelText: 'Username',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                  ),
                                ),
                                enabled: _isEditing,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _usernameController.text = value!;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              //gender
                              if (_isEditing)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Gender",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    DropdownButton(
                                      dropdownColor: const Color(0xFFF4EAE6),
                                      items: list
                                          .map(
                                            (String item) =>
                                                DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
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
                                    floatingLabelStyle:
                                        TextStyle(color: Colors.teal),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: _isEditing,
                                ),
                              const SizedBox(height: 30.0),
                              if (_isEditing)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //Save changes
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        final form = _formKey.currentState;
                                        if (form!.validate()) {
                                          form.save();

                                          saveUserData();
                                          setState(
                                            () {
                                              _isEditing = !_isEditing;
                                            },
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.save_outlined),
                                      label: const Text('Save Changes'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: const BorderSide(
                                            color: Color(0xFFF4EAE6),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                      ),
                                    ),
                                    //Cancel
                                    ElevatedButton.icon(
                                      //cancel
                                      onPressed: () {
                                        loadUserData();
                                        setState(() {
                                          _isEditing = !_isEditing;
                                        });
                                      },
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: const Text('Discard Changes'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: const BorderSide(
                                            color: Color(0xFFF4EAE6),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                //Edit
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = !_isEditing;
                                    });
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(
                                        color: Color(0xFFF4EAE6),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        //delete account button
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              profileController.deleteAccount(
                                context,
                                auth.currentUser,
                              );
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}