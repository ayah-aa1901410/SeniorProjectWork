import 'package:flutter/material.dart';
import '/views/takeTest.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

//Todo
class _HomeState extends State<Home> {
  final rowSpacer = const TableRow(children: [
    SizedBox(
      height: 10,
    ),
    SizedBox(
      height: 10,
    ),
    SizedBox(
      height: 10,
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4EAE6),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                margin: const EdgeInsets.all(7),
                color: Colors.blueGrey[100],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Colors.teal,
                          size: 106,
                        ),
                        Image.asset(
                          'assets/images/health_scale.png',
                          width: 100,
                          height: 60,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 140.0,
                      child: VerticalDivider(
                        thickness: 1.0,
                        width: 6.0,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Table(
                      defaultColumnWidth: const FixedColumnWidth(78.0),
                      children: [
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "SPO2",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "90",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Image(
                            image: AssetImage('assets/images/spo2_icon.png'),
                            width: 30.0,
                            height: 30.0,
                          ),
                        ]),
                        rowSpacer,
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Heart Rate",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "80",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Image(
                              image: AssetImage(
                                  "assets/images/heartrate_icon.png"),
                              width: 25.0,
                              height: 25.0,
                            ),
                          ),
                        ]),
                        rowSpacer,
                        const TableRow(children: [
                          Text(
                            "Body Temperature",
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "37 C",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Image(
                            image:
                                AssetImage("assets/images/bodytemp_icon.png"),
                            width: 25.0,
                            height: 25.0,
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              Image.asset(
                "assets/images/health_overview.PNG",
                width: 350,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[300],
                  fixedSize: const Size(110, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Color(0xFFF4EAE6)),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const TakeTest()));
                },
                child: const Text("Take Test"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
