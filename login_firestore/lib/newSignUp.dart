// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'Login.dart';
//
// class NewSignupPage extends StatefulWidget {
//   @override
//   _NewSignupPageState createState() => _NewSignupPageState();
// }
//
// class _NewSignupPageState extends State<NewSignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _email = '';
//   String _password = '';
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _submitForm() async {
//     final form = _formKey.currentState;
//     if (form!.validate()) {
//       form.save();
//       try {
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: _email,
//           password: _password,
//         );
//         //Navigator.pushReplacementcontext, '/home');
//         Navigator.of(context).pushReplacement(
//             CupertinoPageRoute(builder: (context) => const LoginScreen()));
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'weak-password') {
//           _showErrorDialog('The password provided is too weak.');
//         } else if (e.code == 'email-already-in-use') {
//           _showErrorDialog('The account already exists for that email.');
//         } else {
//           _showErrorDialog('Something went wrong. Please try again later.');
//         }
//       } catch (e) {
//         _showErrorDialog('Something went wrong. Please try again later.');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Signup'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter your email address';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _email = value!;
//                 },
//               ),
//               TextFormField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter a password';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _password = value!;
//                 },
//               ),
//               SizedBox(height: 16.0),
//               ElevatedButton(
//                 child: Text('Sign up'),
//                 onPressed: _submitForm,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Login.dart';

const List<String> list = <String>['Male', 'Female'];

class NewSignupPage extends StatefulWidget {
  @override
  _NewSignupPageState createState() => _NewSignupPageState();
}

class _NewSignupPageState extends State<NewSignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _username = '';
  String _password = '';
  String _confirmPassword = '';
  String _gender = 'Male';
  String _fullName = '';
  int _age = 0;

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _submitForm() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (_password != _confirmPassword) {
        _showErrorDialog(context, 'Passwords do not match.');
        return;
      }
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        String userId = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'username': _username,
          'email': _email,
          'uid': userId,
          'gender': _gender,
          'fullname': _fullName,
          'age': _age,
        });

        final user = FirebaseAuth.instance.currentUser;
        await user!.updateDisplayName(_username);
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const LoginScreen()));
        //Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showErrorDialog(context, 'The password provided is too weak.');
        } else if (e.code == "invalid-email") {
          _showErrorDialog(context, "Invalid email");
        } else if (e.code == 'email-already-in-use') {
          _showErrorDialog(
              context, 'The account already exists for that email.');
        } else {
          _showErrorDialog(
              context, 'Something went wrong. Please try again later.');
        }
      } catch (e) {
        _showErrorDialog(
            context, 'Something went wrong. Please try again later.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
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
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
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
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _age = int.parse(value!);
                  },
                ),
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
                          _gender = value!;
                        });
                      },
                      value: _gender,
                    ),
                    Text(""),
                  ],
                ),
                // DropdownButton<String>(
                //   value: dropdownValue,
                //   icon: const Icon(Icons.arrow_downward),
                //   elevation: 16,
                //   style: const TextStyle(color: Colors.deepPurple),
                //   underline: Container(
                //     height: 2,
                //     color: Colors.deepPurpleAccent,
                //   ),
                //   onChanged: (String? value) {
                //     // This is called when the user selects an item.
                //     setState(() {
                //       dropdownValue = value!;
                //     });
                //   },
                //   items: list.map<DropdownMenuItem<String>>((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Text(value),
                //     );
                //   }).toList(),
                // ),
                // Row(
                //   children: [
                //     Text(
                //       'Gender',
                //       style: TextStyle(
                //         fontSize: 16.0,
                //       ),
                //     ),
                //     Row(
                //       children: [
                //         Radio(
                //           value: 'male',
                //           groupValue: _gender,
                //           onChanged: (value) {
                //             setState(() {
                //               _gender = value!;
                //             });
                //           },
                //         ),
                //         Text('Male'),
                //         SizedBox(width: 20.0),
                //         Radio(
                //           value: 'female',
                //           groupValue: _gender,
                //           onChanged: (value) {
                //             setState(() {
                //               _gender = value!;
                //             });
                //           },
                //         ),
                //         Text('Female'),
                //       ],
                //     ),
                //   ],
                // ),

                // DropdownButtonFormField(
                //   value: _gender,
                //   onChanged: (value) {
                //     setState(() {
                //       _gender = value!;
                //     });
                //   },
                //   items: _genderOptions.map((gender) {
                //     return DropdownMenuItem(
                //       value: gender,
                //       child: Text(gender),
                //     );
                //   }).toList(),
                //   decoration: InputDecoration(
                //     labelText: 'Gender',
                //   ),
                //   validator: (value) {
                //     if (value == null) {
                //       return 'Please select your gender';
                //     }
                //     return null;
                //   },
                // ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm(),
                  child: Text('Signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
