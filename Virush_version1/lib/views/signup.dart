import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/signup_controller.dart';
import 'login.dart';

const List<String> list = <String>['Male', 'Female'];

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final signupController = Get.put(SignupController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  String _email = 'ehh';
  String _username = '';
  String _password = '';
  String _confirmPassword = '';
  String _gender = 'Male';
  String _fullName = '';
  DateTime _dateofBirth = DateTime.now();
  int _age = 0;

  bool _isHidden = true;

  void _toggleVisibility() {
    setState(
      () {
        _isHidden = !_isHidden;
      },
    );
  }

  // void _showErrorDialog(BuildContext context, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.blueGrey[50],
  //         title: Container(
  //           padding: EdgeInsets.all(15),
  //           decoration: const BoxDecoration(
  //             color: Colors.teal,
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(10.0),
  //               topRight: Radius.circular(10.0),
  //             ),
  //           ),
  //           child: const Text(
  //             "Error",
  //             style: TextStyle(
  //               color: Color(0xFFF4EAE6),
  //             ),
  //           ),
  //         ),
  //         titlePadding: const EdgeInsets.all(0),
  //         content: Text(message),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         actions: <Widget>[
  //           MaterialButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             color: Colors.red.shade200,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(3.0),
  //               side: BorderSide(color: Colors.blueGrey.shade700, width: 2.0),
  //             ),
  //             child: const Text("Accept"),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // _submitForm() async {
  //   final form = _formKey.currentState;
  //   if (form!.validate()) {
  //     form.save();
  //     if (_password != _confirmPassword) {
  //       _showErrorDialog(context, 'Passwords do not match.');
  //       return;
  //     }
  //     try {
  //       UserCredential userCredential =
  //           await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //         email: _email,
  //         password: _password,
  //       );
  //       String userId = userCredential.user!.uid;
  //
  //       await FirebaseFirestore.instance.collection('users').doc(userId).set({
  //         'username': _username,
  //         'email': _email,
  //         'uid': userId,
  //         'gender': _gender,
  //         'fullname': _fullName,
  //         'age': _age,
  //       });
  //
  //       final user = FirebaseAuth.instance.currentUser;
  //       await user!.updateDisplayName(_username);
  //       Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (context) => const Login()));
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'weak-password') {
  //         _showErrorDialog(context, 'The password provided is too weak.');
  //       } else if (e.code == "invalid-email") {
  //         _showErrorDialog(context, "Invalid email");
  //       } else if (e.code == 'email-already-in-use') {
  //         _showErrorDialog(
  //             context, 'The account already exists for that email.');
  //       } else {
  //         _showErrorDialog(
  //             context, 'Something went wrong. Please try again later.');
  //       }
  //     } catch (e) {
  //       _showErrorDialog(
  //           context, 'Something went wrong. Please try again later.');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 40.0,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                        backgroundColor: Color(0xFFF4EAE6),
                      ),
                      Text(
                        "Virush",
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 25.0,
                          color: Color(0xFFF4EAE6),
                          //fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EAE6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        //email container
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Colors.teal,
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color: Colors.teal),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Email',
                              // Focus Color underline
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                              //print("==========" + _email);
                            },
                          ),
                        ),
                        //username container
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            cursorColor: Colors.teal,
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color: Colors.teal),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Username',
                              // Focus Color underline
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a username';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _username = value!;
                            },
                          ),
                        ),
                        //password container
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            obscureText: _isHidden,
                            cursorColor: Colors.teal,
                            decoration: InputDecoration(
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.teal),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Password',
                              // Focus Color underline
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_isHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                color: Colors.blueGrey[600],
                                onPressed: _toggleVisibility,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                        ),
                        //confirm password container
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            obscureText: _isHidden,
                            cursorColor: Colors.teal,
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color: Colors.teal),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Confirm Password',
                              // Focus Color underline
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                              // suffixIcon: IconButton(
                              //   icon: Icon(_isHidden
                              //       ? Icons.visibility_off
                              //       : Icons.visibility),
                              //   color: Colors.blueGrey[600],
                              //   onPressed: _toggleVisibility,
                              // ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please confirm your password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _confirmPassword = value!;
                            },
                          ),
                        ),
                        //full name
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            cursorColor: Colors.teal,
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color: Colors.teal),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Full name',
                              // Focus Color underline
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _fullName = value!;
                            },
                          ),
                        ),
                        //age
                        // Container(
                        //   padding: const EdgeInsets.all(5.0),
                        //   child: TextFormField(
                        //     keyboardType: TextInputType.number,
                        //     cursorColor: Colors.teal,
                        //     decoration: const InputDecoration(
                        //       floatingLabelStyle: TextStyle(color: Colors.teal),
                        //       floatingLabelBehavior:
                        //           FloatingLabelBehavior.always,
                        //       labelText: 'Age',
                        //       // Focus Color underline
                        //       focusedBorder: UnderlineInputBorder(
                        //         borderSide: BorderSide(color: Colors.teal),
                        //       ),
                        //     ),
                        //     validator: (value) {
                        //       if (value!.isEmpty) {
                        //         return 'Please enter your age';
                        //       }
                        //       return null;
                        //     },
                        //     onSaved: (value) {
                        //       _age = int.parse(value!);
                        //     },
                        //   ),
                        // ),
                        //dob
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            readOnly: true,
                            cursorColor: Colors.teal,
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color: Colors.teal),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Date of Birth',
                              // Focus Color underline
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                            ),
                            controller: _dobController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your date of birth';
                              }
                              return null;
                            },
                            // onSaved: (value) {
                            //   _dobController.text = value!;
                            //   // _age = signupController
                            //   //     .getAge(); //set output date to TextField value.
                            //   // print("===============Age ${_age.toString()}");
                            //   print("fdfrfre ${value}");
                            // },
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors.teal,
                                        onPrimary: Color(0xFFF4EAE6),
                                        onSurface: Colors.blueGrey,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.teal,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                print(
                                    pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                print(
                                    formattedDate); //formatted date output using intl package =>  2021-03-16
                                //you can implement different kind of Date Format here according to your requirement

                                setState(() {
                                  _dobController.text = formattedDate;
                                  _dateofBirth = pickedDate;
                                  _age = signupController.getAge(pickedDate);
                                });
                              } else {
                                print("Date is not selected");
                              }
                            },
                            // onTap: () {
                            //   FocusScope.of(context).unfocus();
                            //
                            //   // Show date picker dialog
                            //   DatePicker.showDatePicker(
                            //     context,
                            //     showTitleActions: true,
                            //     minTime: DateTime(1900, 1, 1),
                            //     maxTime: DateTime(2005, 12, 31),
                            //     onConfirm: (date) {
                            //       // Set the selected date to the date of birth text field
                            //       _dobController.text =
                            //           '${date.year}-${date.month}-${date.day}';
                            //       int age = signupController.getAge(date);
                            //       print('===============Age: $age');
                            //       _age = age;
                            //     },
                            //     currentTime: DateTime.now(),
                            //     locale: LocaleType.en,
                            //   );
                            // },
                          ),
                        ),
                        //gender
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Gender",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              DropdownButton(
                                dropdownColor: Color(0xFFF4EAE6),
                                selectedItemBuilder: (BuildContext context) {
                                  return <String>[
                                    'Female',
                                    'Male',
                                  ].map((String value) {
                                    return Container(
                                      child: Text(
                                        _gender,
                                      ),
                                      width: 70,
                                      alignment: Alignment.center,
                                    );
                                  }).toList();
                                },
                                items: list
                                    .map((String item) =>
                                        DropdownMenuItem<String>(
                                            value: item,
                                            child: Container(
                                              child: Text(
                                                item,
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                              alignment: Alignment.center,
                                            )))
                                    .toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                                value: _gender,
                              ),
                              const Text(""),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade200,
                      fixedSize: const Size(110, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                            color: Colors.blueGrey.shade700, width: 2.0),
                      ),
                    ),
                    onPressed: () {
                      //print("gregre ========== ${_age}");
                      final form = _formKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        if (_password != _confirmPassword) {
                          signupController.showErrorDialog(
                              context, 'Passwords do not match.');
                          return;
                        } else if (!signupController
                            .isStrongPassword(_password)) {
                          signupController.showErrorDialog(context,
                              'Password must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one digit, and one special character.');
                          return;
                        } else if (!signupController.isValidAge(_age)) {
                          signupController.showErrorDialog(context,
                              'You must be at least 18 years old to create an account.');
                          return;
                        }

                        print("aaa=========== ${_dateofBirth}");

                        signupController.submitForm(
                          context,
                          _email,
                          _username,
                          _password,
                          _confirmPassword,
                          _gender,
                          _fullName,
                          _dateofBirth,
                        );
                      }
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
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Already have an account?',
                          style:
                              TextStyle(fontSize: 15, color: Colors.red[100]),
                        ),
                        TextButton(
                          child: Text(
                            'Log in',
                            style: TextStyle(
                                fontSize: 20, color: Colors.blueGrey[100]),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const Login()));
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}
