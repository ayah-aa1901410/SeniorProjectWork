import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var client = http.Client();

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
  // var filePath = 'C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Audio Recorder Mob App - ML\\';

  var filePath = './audio';

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future startRecord() async {
    await recorder.startRecorder(toFile: filePath);
  }

  Future stopRecorder() async {
    filePath = (await recorder.stopRecorder())!;
    final file = File(filePath);
    print('Recorded file path: $filePath');
    // print('Recorded file: $file');
  }

  Future startPlaying() async {
    audioPlayer.open(
      Audio.file(filePath),
      autoStart: true,
      showNotification: true,
    );
    classifyAudio();
  }

  Future<void> classifyAudio() async {
    String url = "http://10.0.2.2:8000/predict";
    // print("url");
    // final response = await http.get(Uri.parse(url));
    // print("sending request");
    // final result = await json.decode(response.body);
    // print("got the result");

    // String url = "http://192.168.10.44:8000/predict";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    print("here established connection");
    request.files.add(await http.MultipartFile.fromPath("audio", filePath));
    print("second part established connection");
    print(filePath);
    try {
      final streamedResponse = await request.send().timeout(Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      print(data);
    } on SocketException catch (e) {
      print('SocketException: $e');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
    } catch (e) {
      print('Error: $e');
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
              const Text(
                'Press to start/stop recording',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF7FD9E5),
                  fixedSize: const Size(100, 100),
                  shape: const CircleBorder(),
                ),
                onPressed: () async {
                  if (recorder.isRecording) {
                    await stopRecorder();
                    await startPlaying();
                    setState(() {});
                  } else {
                    await startPlaying();
                    setState(() {});
                  }
                },
                child: const Icon(
                  Icons.play_arrow,
                  size: 60,
                ),
              ),
            ],
          ),
        ));
  }

}
