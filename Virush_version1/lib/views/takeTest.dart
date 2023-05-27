import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class TakeTest extends StatefulWidget {
  const TakeTest({Key? key}) : super(key: key);

  @override
  State<TakeTest> createState() => _TakeTestState();
}

class _TakeTestState extends State<TakeTest> {
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
    await recorder.startRecorder(toFile: "audio");
  }

  Future stopRecorder() async {
    filePath = (await recorder.stopRecorder())!;
    final file = File(filePath);
    print('Recorded file path: $filePath');
  }

  Future startPlaying() async {
    audioPlayer.open(
      Audio.file(filePath),
      autoStart: true,
      showNotification: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virush'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Color(0xFFF4EAE6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<RecordingDisposition>(
              builder: (context, snapshot) {
                final duration =
                    snapshot.hasData ? snapshot.data!.duration : Duration.zero;

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
                recorder.isRecording
                    ? Icons.mic_off_rounded
                    : Icons.mic_rounded,
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
                primary: Colors.teal,
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
      ),
    );
  }
}
