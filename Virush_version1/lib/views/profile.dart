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
    //_gender = userData['gender'];
    _usernameController.text = userData['username'];
  }

  Future<void> saveUserData() async {
    await _userRef.set({
      'fullname': _nameController.text,
      //'age': int.parse(_ageController.text),
      'gender': _genderController.text,
      'username': _usernameController.text,
    }, SetOptions(merge: true));
  }

  //final text_style = TextStyle(fontSize: 15, color: Colors.blueGrey[700]);
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //header column
                      Column(
                        children: [
                          //logout + name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Card(
                                color: Colors.blueGrey[200],
                                margin: const EdgeInsets.all(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 7.0),
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
                                          //"sAra Ahmad",
                                          controller: _nameController,
                                          style: const TextStyle(fontSize: 20),
                                          enabled: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //logout
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
                            //age
                            TextField(
                              controller: _ageController,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: false,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Gender",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  DropdownButton(
                                    dropdownColor: Color(0xFFF4EAE6),
                                    items: list
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
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
                            const SizedBox(height: 30.0),
                            if (_isEditing)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //Save changes
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      saveUserData();
                                      setState(() {
                                        _isEditing = !_isEditing;
                                      });
                                    },
                                    icon: const Icon(Icons.save_outlined),
                                    label: const Text('Save Changes'),
                                    //Edit button
                                    // ElevatedButton.icon(
                                    //   icon: const Icon(Icons.edit_outlined),
                                    //   label: const Text("Edit"),
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: Colors.red[300],
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.circular(10.0),
                                    //       side: const BorderSide(
                                    //           color: Color(0xFFF4EAE6)),
                                    //     ),
                                    //   ),
                                    // ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                            color: Color(0xFFF4EAE6)),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 10),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    //cancel
                                    onPressed: () {
                                      loadUserData();
                                      setState(() {
                                        _isEditing = !_isEditing;
                                      });
                                    },
                                    icon: const Icon(Icons.cancel_outlined),
                                    label: const Text('Cancel'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                            color: Color(0xFFF4EAE6)),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 10),
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
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: const BorderSide(
                                        color: Color(0xFFF4EAE6)),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                              ),
                          ],
                        ),
                        // child: Table(
                        //   children: [
                        //     TableRow(
                        //       children: [
                        //         Text(
                        //           "Username:",
                        //           style: text_style,
                        //         ),
                        //         Text(
                        //           "Sarah_ahmed",
                        //           style: text_style,
                        //         ),
                        //       ],
                        //     ),
                        //     TableRow(
                        //       children: [
                        //         Text(
                        //           "First Name",
                        //           style: text_style,
                        //         ),
                        //         Text(
                        //           "Sarah",
                        //           style: text_style,
                        //         ),
                        //       ],
                        //     ),
                        //     TableRow(
                        //       children: [
                        //         Text(
                        //           "Last Name:",
                        //           style: text_style,
                        //         ),
                        //         Text(
                        //           "Ahmad:",
                        //           style: text_style,
                        //         ),
                        //       ],
                        //     ),
                        //     TableRow(
                        //       children: [
                        //         Text(
                        //           "Email Address:",
                        //           style: text_style,
                        //         ),
                        //         Text(
                        //           "sarah123@yahoo.com",
                        //           style: text_style,
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                      ),
                      //const SizedBox(height: 300),
                      //delete
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            profileController.deleteAccount(
                                context, auth.currentUser);
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
