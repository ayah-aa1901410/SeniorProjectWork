import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virush_version2/controller/health_data_controller.dart';
import 'dart:convert';
import 'package:get/get.dart';

class TakeTest extends StatefulWidget {
  const TakeTest({Key? key}) : super(key: key);

  @override
  State<TakeTest> createState() => _TakeTestState();
}

class _TakeTestState extends State<TakeTest> {
  var finishedRecording = true;
  var _displayText = 'Press to start/stop recording';
  var _textColor = const Color.fromRGBO(117, 117, 117, 1.0);
  var _NFCTextInstruction_Color = const Color.fromRGBO(229, 127, 132, 1.0);
  var _NFCConnectionColor = const Color.fromRGBO(229, 127, 132, 1.0);
  bool _isLoading = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  late final User _user;
  final CollectionReference recordsRef =
  FirebaseFirestore.instance.collection('records');

  TextEditingController spo2 = TextEditingController();
  TextEditingController heartrate = TextEditingController();
  TextEditingController bodytemperature = TextEditingController();

  String userHealth = "Healthy";

  final healthDataController = Get.put(HealthDataController());

  bool _NFCconnected = false;
  var connectionText = "Wristband not connected";
  var NFC_instruction = "Please put your phone over the wristband.";
  bool _hideHealthData = false;

  bool discardHealthData = false;

  @override
  void initState() {
    initRecorder();
    super.initState();
    super.initState();
    _user = auth.currentUser!;

    spo2.text = "-1";
    heartrate.text = "-1";
    bodytemperature.text = "-1";
    getHealthData();
  }

  void getHealthData() async {
    List<SensorData> sensorDataList = await healthDataController.getHealthData();

    if(sensorDataList[0].data == '-1' && sensorDataList[1].data == '-1' && sensorDataList[2].data == '-1'){
      setState(() {
        _NFCconnected = false;
        connectionText = "Wristband not connected";
        NFC_instruction = "Please put your phone over the wristband.";
        _NFCConnectionColor = const Color.fromRGBO(229, 127, 132, 1.0);
        _NFCTextInstruction_Color = const Color.fromRGBO(229, 127, 132, 1.0);

      });
    }else{
      setState(() {
        _NFCconnected = true;
        connectionText = "Wristband Connected";
        NFC_instruction = "Data is being read. Please hold still.";
        _NFCConnectionColor = const Color.fromRGBO(65 , 161, 145, 1.0);
        _NFCTextInstruction_Color = const Color.fromRGBO(65 , 161, 145, 1.0);
      });

      heartrate.text = sensorDataList[0].data;
      bodytemperature.text = sensorDataList[1].data;
      spo2.text = sensorDataList[2].data;

    }
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  final recorder = FlutterSoundRecorder();
  final audioPlayer = AssetsAudioPlayer();
  bool isRecording = false;
  var filePath = '';

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future startRecord() async {
    setState(() {
      _displayText = 'Recording started.';
      _textColor = Color.fromRGBO(117, 117, 117, 1.0);
    });
    final directory = await getApplicationDocumentsDirectory();
    final fileLocation = '${directory.path}/audio.wav';
    await recorder.startRecorder(toFile: fileLocation, codec: Codec.pcm16WAV);
    // _result = "";
  }

  Future stopRecorder() async {
    setState(() {
      _isLoading = false;
      _displayText = "Recording stopped.\nConnecting to Server ...";
      _textColor = const Color.fromRGBO(65 , 161, 145, 1.0);
    });
    filePath = (await recorder.stopRecorder())!;
    final file = File(filePath);
    print('Recorded file path: $filePath');
    setState(() {
      finishedRecording = false;
    });
    await Future.delayed(Duration(seconds: 2));
    classifyAudio();
  }

  Future startPlaying() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileLocation = '${directory.path}/audio.wav';
    audioPlayer.open(
      Audio.file(fileLocation),
      autoStart: true,
      showNotification: true,
    );
    classifyAudio();
  }

  Future<void> classifyAudio() async {
    // String url = "http://192.168.10.44:8000/predict";
    String url = "http://10.75.46.151:8000/predict";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    print("here established connection");
    final directory = await getApplicationDocumentsDirectory();
    final fileLocation = '${directory.path}/audio.wav';
    final file = File(fileLocation);
    setState(() {
      _isLoading = true;
      _displayText = "Waiting for Server\nto analyze cough ...";
      _textColor = const Color.fromRGBO(65 , 161, 145, 1.0);
    });
    if (await file.exists()) {
      try {
        request.files
            .add(await http.MultipartFile.fromPath("audio.wav", fileLocation));
        print("second part established connection");
        print(fileLocation);
        final streamedResponse =
        await request.send().timeout(Duration(seconds: 60));
        final response = await http.Response.fromStream(streamedResponse);
        // final data = jsonDecode(response.body);
        final jsonData = jsonDecode(response.body);
        final result = jsonData['result'].toString();
        if (result != null) {
          setState(() {
            if (result.toString() == "0") {
              _displayText = "Healthy";
              _textColor = const Color.fromRGBO(65 , 161, 145, 1.0);
            } else if (result.toString() == "1") {
              _displayText = "COVID-19";
              _textColor = const Color.fromRGBO(229, 127, 132, 1.0);
            } else {
              _displayText = "Please record your cough sound only.";
              _textColor = const Color.fromRGBO(229, 127, 132, 1.0);
            }
          });
        }
        print(result);
        print(_displayText);
      } on SocketException catch (e) {
        setState(() {
          _displayText = "Couldn't connect to Server";
          _textColor = const Color.fromRGBO(229, 127, 132, 1.0);
        });
        print('SocketException: $e');
      } on TimeoutException catch (e) {
        setState(() {
          _displayText = "Couldn't connect to Server";
          _textColor = const Color.fromRGBO(229, 127, 132, 1.0);
        });
        print('TimeoutException: $e');
      } catch (e) {
        setState(() {
          _displayText = "Couldn't connect to Server";
          _textColor = const Color.fromRGBO(229, 127, 132, 1.0);
        });
        print('Error: $e');
      }finally{
        setState(() {
          _isLoading = false;
        });
      }

    } else {
      print("Could not locate file");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
          ),
          title: const Text('Dashboard', style: TextStyle(fontSize: 23, fontFamily: 'Roboto', fontWeight: FontWeight.bold),),
          backgroundColor: const Color.fromRGBO(65 , 161, 145, 1.0),
        ),
        backgroundColor: const Color(0xFFF4EAE6),

        body:Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Text(
                "The test consists of two parts:\n1. Recording your Cough Sound\n2. Reading your Biometric Data\nThe final result will be displayed after\nboth parts are completed.",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(117, 117, 117, 1.0),
                  wordSpacing: 1.2
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 200, minWidth: 500),
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      elevation: 7,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                        child: Column(
                          children: [
                            const Text(
                              "Cough Test",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(47, 80, 97, 1.0)
                              ),
                            ),
                            SizedBox(height: 15,),
                            Visibility(
                                visible: finishedRecording,
                                child: Column(
                                  children: [
                                    StreamBuilder<RecordingDisposition>(
                                      builder: (context, snapshot) {
                                        final duration = snapshot.hasData
                                            ? snapshot.data!.duration
                                            : Duration.zero;

                                        String twoDigits(int n) =>
                                            n.toString().padLeft(2, '0');

                                        final twoDigitMinutes =
                                        twoDigits(duration.inMinutes.remainder(60));
                                        final twoDigitSeconds =
                                        twoDigits(duration.inSeconds.remainder(60));

                                        return Text(
                                          '$twoDigitMinutes:$twoDigitSeconds',
                                          style: const TextStyle(
                                            color: Color.fromRGBO(117, 117, 117, 1.0),
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                      stream: recorder.onProgress,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE57F84),
                                        fixedSize: const Size(150, 150),
                                        shape: const CircleBorder(),
                                      ),
                                      onPressed: () async {
                                        if (recorder.isRecording) {
                                          await stopRecorder();
                                          setState(() {});
                                        } else {
                                          await startRecord();
                                          setState(() {});
                                        }
                                      },
                                      child: Icon(
                                        recorder.isRecording ? Icons.stop : Icons.mic,
                                        size: 100,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                )),
                            Center(
                              child: _isLoading
                                  ?
                              Column(
                                children: [
                                  CircularProgressIndicator(color: Color.fromRGBO(65 , 161, 145, 1.0),),
                                  Text(
                                    _displayText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: _textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ):
                              Text(
                                _displayText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: _textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 200, minWidth: 500),
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      elevation: 7,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                        child: Column(
                          children: [
                            const Text(
                              "Biometric Data Test",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(47, 80, 97, 1.0)
                              ),
                            ),
                            Visibility(
                                visible: _NFCconnected,
                                child: ElevatedButton(
                                  onPressed:  getHealthData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(47, 80, 97, 1.0),
                                    elevation: 7,
                                    minimumSize: Size(130, 40),
                                    textStyle: TextStyle(fontSize: 17),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  child: const Text('Read Health Data', style: TextStyle(fontWeight: FontWeight.bold),),
                                  // onPressed: healthDataController.readData(),
                                )
                            ),
                            const SizedBox(height: 20),
                            Visibility(
                              visible: !_hideHealthData,
                              child: Text(
                                connectionText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: _NFCConnectionColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Visibility(
                              visible: !_hideHealthData,
                              child: Text(
                                NFC_instruction,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: _NFCTextInstruction_Color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Visibility(
                              visible: _hideHealthData,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Unable to read Biometric Data.",
                                    style: TextStyle(fontSize: 18, color: Color.fromRGBO(229, 127, 132, 1.0)),
                                  ),
                                  Text(
                                    "The final result will be based\non the Cough Test only.",
                                    style: TextStyle(fontSize: 18, color: Color.fromRGBO(47, 80, 97, 1.0),),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _hideHealthData = false;
                                        discardHealthData = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      //const Color(0xFFF4EAE6), // Set the button's background color
                                      minimumSize: const Size(
                                        120,
                                        40,
                                      ), // Set the button's minimum dimensions
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12), // Set the border radius
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Get Health Data',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Color.fromRGBO(47, 80, 97, 1.0),
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 0.7
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ),
                          ],
                        ),
                      )

                    ),
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: !finishedRecording,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          finishedRecording = true;
                          _displayText = "Press to start/stop recording.";
                          _textColor = const Color.fromRGBO(117, 117, 117, 1.0);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color.fromRGBO(47, 80, 97, 1.0), // Set the button's background color
                        minimumSize: const Size(
                          150,
                          50,
                        ), // Set the button's minimum dimensions
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15), // Set the border radius
                        ),
                      ),
                      child: const Text(
                        'Retake Test',
                        style: TextStyle(
                          fontSize: 23.0,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: !_hideHealthData,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10,10,10,15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Unable to record Health Data?',
                        style: TextStyle(fontSize: 15, color: Color.fromRGBO(47, 80, 97, 1.0),),
                      ),
                      TextButton(
                        child: Text(
                          'Test with Cough only.',
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromRGBO(65 , 161, 145, 1.0),
                              decoration: TextDecoration.underline,
                              decorationThickness: 0.7
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _NFCconnected = false;
                            _hideHealthData = true;
                            discardHealthData = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              )
            ),
          ],
        )
    );
  }
}
