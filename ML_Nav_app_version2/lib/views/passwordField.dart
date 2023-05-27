import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _ishidden = true;

  void _toggleVisibility() {
    setState(
      () {
        _ishidden = !_ishidden;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        obscureText: _ishidden ? true : false,
        cursorColor: Colors.red.shade400,
        style: TextStyle(color: Colors.blueGrey),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(_ishidden ? Icons.visibility_off : Icons.visibility),
            color: Colors.blueGrey[600],
            onPressed: _toggleVisibility,
          ),
          border: InputBorder.none,
          hintText: "Password",
          hintStyle: TextStyle(
            color: Colors.blueGrey.shade200,
          ),
        ),
      ),
    );
  }
}
