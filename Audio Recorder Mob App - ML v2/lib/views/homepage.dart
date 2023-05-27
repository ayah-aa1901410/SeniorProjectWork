import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var finishedRecording = true;
  var _displayText = 'Press to start/stop recording';
  var _textColor = Colors.grey;
  @override
  void initState() {
    initRecorder();
    super.initState();
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
    setState((){
      _displayText = 'Recording started.';
      _textColor = Colors.grey;
    });
    final directory = await getApplicationDocumentsDirectory();
    final fileLocation = '${directory.path}/audio.wav';
    await recorder.startRecorder(toFile: fileLocation, codec: Codec.pcm16WAV);
    // _result = "";
  }

  Future stopRecorder() async {
    setState(() {
      _displayText = 'Recording stopped. \nAnalyzing cough.';
      _textColor = Colors.green;
    });
    filePath = (await recorder.stopRecorder())!;
    final file = File(filePath!);
    print('Recorded file path: $filePath');
    classifyAudio();
    setState(() {
      finishedRecording = false;
    });
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
    // String url = "http://10.0.2.2:8000/predict";
    // String url = "http://192.168.10.44:8000/predict";
    // print("url");
    // final response = await http.get(Uri.parse(url));
    // print("sending request");
    // final result = await json.decode(response.body);
    // print("got the result");
    // print(result);

    String url = "http://192.168.10.44:8000/predict";
    // String url = "http://127.0.0.1:8000/predict";


    var request = http.MultipartRequest('POST', Uri.parse(url));
    print("here established connection");

    final directory = await getApplicationDocumentsDirectory();
    final fileLocation = '${directory.path}/audio.wav';
// .wav
    final file = File(fileLocation);
    if (await file.exists()) {
      request.files.add(await http.MultipartFile.fromPath("audio.wav", fileLocation));
      print("second part established connection");
      print(fileLocation);
      final streamedResponse = await request.send().timeout(Duration(seconds: 240));
      final response = await http.Response.fromStream(streamedResponse);
      // final data = jsonDecode(response.body);
      final jsonData = jsonDecode(response.body);
      final result = jsonData['result'].toString();
      if (result != null) {
        setState(() {
          if(result.toString() == "0"){
            _displayText = "Healthy";
            _textColor = Colors.lightGreen;
          }else if(result.toString() == "0"){
            _displayText = "COVID-19";
            _textColor = Colors.redAccent as MaterialColor;
          }else{
            _displayText = "Please record your cough sound only.";
            _textColor = Colors.red;
          }
        });
      }
      print(result);
      print(_displayText);
      // try {
      //
      // } on SocketException catch (e) {
      //   print('SocketException: $e');
      // } on TimeoutException catch (e) {
      //   print('TimeoutException: $e');
      // } catch (e) {
      //   print('Error: $e');
      // }

    } else {
      print("Could not locate file");
    }

    // print("Classifying Result: $result");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4EAE6),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Visibility(
                 visible: finishedRecording,
                 child: Column(
                   children: [
                     StreamBuilder<RecordingDisposition>(
                       builder: (context, snapshot) {
                         final duration = snapshot.hasData
                             ? snapshot.data!.duration
                             : Duration.zero;

                         String twoDigits(int n) => n.toString().padLeft(2, '0');

                         final twoDigitMinutes =
                         twoDigits(duration.inMinutes.remainder(60));
                         final twoDigitSeconds =
                         twoDigits(duration.inSeconds.remainder(60));

                         return Text(
                           '$twoDigitMinutes:$twoDigitSeconds',
                           style: const TextStyle(
                             color: Colors.grey,
                             fontSize: 50,
                             fontWeight: FontWeight.bold,
                           ),
                         );
                       },
                       stream: recorder.onProgress,
                     ),
                     const SizedBox(height: 20),
                     ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         primary: const Color(0xFFE57F84),
                         fixedSize: const Size(170, 170),
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
                 )
               ),
              Center(
                child: Text(
                  _displayText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: _textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    finishedRecording = true;
                    _displayText = "Press to start/stop recording.";
                    _textColor = Colors.grey;
                  });
                },
                child: Text('Retake Test', style: TextStyle(
                  fontSize: 25.0,
                  // fontWeight: FontWeight.bold,
                  color: Colors.white
                ),),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Set the button's background color
                  minimumSize: Size(200, 50), // Set the button's minimum dimensions
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Set the border radius
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
