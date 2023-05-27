import 'package:flutter/foundation.dart';
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
  String _email = '';
  String _username = '';
  String _password = '';
  String _confirmPassword = '';
  String _gender = 'Male';
  String _fullName = '';
  DateTime _dateOfBirth = DateTime.now();
  int _age = 0;

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
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //logo and app name
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
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  //Fields
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
                        //full name container
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            cursorColor: Colors.teal,
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color: Colors.teal),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Full Name',
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
                        //Date of Birth container
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
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                setState(() {
                                  _dobController.text = formattedDate;
                                  _dateOfBirth = pickedDate;
                                  _age = signupController.getAge(pickedDate);
                                });
                              } else {
                                if (kDebugMode) {
                                  print("Date is not selected");
                                }
                              }
                            },
                          ),
                        ),
                        //gender container
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //gender text
                              Text(
                                "Gender",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              //dropdown
                              DropdownButton(
                                dropdownColor: const Color(0xFFF4EAE6),
                                selectedItemBuilder: (BuildContext context) {
                                  return <String>[
                                    'Female',
                                    'Male',
                                  ].map((String value) {
                                    return Container(
                                      width: 70,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _gender,
                                      ),
                                    );
                                  }).toList();
                                },
                                items: list
                                    .map((String item) =>
                                        DropdownMenuItem<String>(
                                            value: item,
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                item,
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                            )))
                                    .toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                                value: _gender,
                              ),
                              //For spacing purposes
                              const Text(""),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Signup button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade200,
                      fixedSize: const Size(110, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                          color: Colors.blueGrey.shade700,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onPressed: () {
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

                        signupController.submitForm(
                          context,
                          _email,
                          _username,
                          _password,
                          _confirmPassword,
                          _gender,
                          _fullName,
                          _dateOfBirth,
                        );
                      }
                    },
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                  ),
                  //Already have account, navigate to login
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
