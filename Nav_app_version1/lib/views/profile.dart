import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final text_style = TextStyle(fontSize: 15, color: Colors.blueGrey[700]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Card(
                    color: Colors.blueGrey[100],
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 70,
                              ),
                              Text(
                                "Sarah Ahmad",
                                style: TextStyle(fontSize: 25),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                    width: 330,
                    child: Divider(
                      color: Colors.blueGrey,
                      thickness: 1.5,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[300],
                      fixedSize: const Size(170, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.yellow.shade50),
                      ),
                    ),
                    onPressed: () {},
                    child: const ListTile(
                      leading: Icon(Icons.edit),
                      title: Text("Edit"),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    TableRow(
                      children: [
                        Text(
                          "Username:",
                          style: text_style,
                        ),
                        Text(
                          "Sarah_ahmed",
                          style: text_style,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          "First Name",
                          style: text_style,
                        ),
                        Text(
                          "Sarah",
                          style: text_style,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          "Last Name:",
                          style: text_style,
                        ),
                        Text(
                          "Ahmad:",
                          style: text_style,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          "Email Address:",
                          style: text_style,
                        ),
                        Text(
                          "sarah123@yahoo.com",
                          style: text_style,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[300],
                  fixedSize: const Size(140, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.yellow.shade50),
                  ),
                ),
                onPressed: () {},
                child: const Text("Delete Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
