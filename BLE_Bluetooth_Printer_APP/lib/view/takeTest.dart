import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:ble_data_converter/ble_data_converter/src/ble_data_converter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:virush_version2/controller/health_data_controller.dart';
import 'dart:convert';

class TakeTest extends StatefulWidget {
  @override
  State<TakeTest> createState() => _TakeTestState();
}

class _TakeTestState extends State<TakeTest> {

  var finishedRecording = true;
  var finishedHealthTest = false;
  var retakeTest = false;
  var _displayTextCough = 'Press to start/stop recording';
  var _displayTextHData = '';
  var _textColorCough = const Color.fromRGBO(117, 117, 117, 1.0);
  var _textColorHData = const Color.fromRGBO(117, 117, 117, 1.0);
  var _NFCTextInstruction_Color = const Color.fromRGBO(229, 127, 132, 1.0);
  var _NFCConnectionColor = const Color.fromRGBO(229, 127, 132, 1.0);
  bool _isLoadingCough = false;
  bool _isLoadingHData = false;

  bool _NFCconnected = false;
  var connectionText = "Wristband not connected";
  var NFC_instruction = "Press the button to connect.";
  bool _hideHealthData = false;

  bool discardHealthData = false;


  bool isConnected = false;
  FlutterBluePlus? flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? esp32Device;

  double tempText = 0.0;
  int pulseText = 0;
  int spo2Text = 0;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _tempCharacteristic;
  BluetoothCharacteristic? _pulseCharacteristic;
  BluetoothCharacteristic? _spo2Characteristic;

  List<double> tempList = [];
  List<int> pulseList = [];
  List<int> spo2List = [];

  int counter = 0;

  TextEditingController spo2 = TextEditingController();
  TextEditingController heartrate = TextEditingController();
  TextEditingController bodytemperature = TextEditingController();

  @override
  void initState() {
    initRecorder();
    super.initState();
    _user = auth.currentUser!;

    spo2.text = "-1";
    heartrate.text = "-1";
    bodytemperature.text = "-1";
    //getHealthData();
    counter = 0;

    print(counter);
    print(spo2.text);
    print(bodytemperature.text);
    print(heartrate.text);
    print(spo2List.length.toString());
    print(pulseList.length.toString());
    print(tempList.length.toString());

  }

  FirebaseAuth auth = FirebaseAuth.instance;
  late final User _user;
  final CollectionReference recordsRef =
  FirebaseFirestore.instance.collection('records');

  var finalHealth = "";
  var coughResult = '';
  var healthDResult = '';
  bool _isFinalOut = false;

  final recorder = FlutterSoundRecorder();
  final audioPlayer = AssetsAudioPlayer();
  bool isRecording = false;
  var filePath = '';

  Future<void> addRecord() async {
    print("inside add record");
    final CollectionReference recordsRef =
    FirebaseFirestore.instance.collection('records');

    // Create a new document with the three random values and additional fields
    final Map<String, dynamic> data = <String, dynamic>{
      'uid': _user.uid,
      'heart_rate': heartrate.text != "-1"? heartrate.text: "--",
      'body_temperature': bodytemperature.text != "-1"? bodytemperature.text : "--",
      'spo2': spo2.text != "-1"? spo2.text : "--",
      'current_date_time': DateTime.now(),
      'cough_sound_result': coughResult.toString(),
      'stat_ml_result': healthDResult.isEmpty?"--": healthDResult.toString(),
      'overall_health': finalHealth.toString(),
    };

    print('cough_sound_result: ' + coughResult.toString());
    print('stat_ml_result: ' + healthDResult.toString());
    print('overall_health: ' +  finalHealth.toString());
    print("created the object");
    print("data: " + data.toString());

    await recordsRef.add(data);
    print("added record");
  }

  Future<void> checkResults() async{
    if(_hideHealthData == false){
        if(coughResult != "" && healthDResult != ""){
          if(coughResult == "Healthy" && healthDResult == "Healthy"){
            finalHealth = "Healthy";
          }else if(coughResult == "COVID-19" && healthDResult == "COVID-19"){
            finalHealth = "COVID-19";
          }else if(coughResult == "Healthy" && healthDResult == "COVID-19" || coughResult == "COVID-19" && healthDResult == "Healthy"){
            finalHealth = "Symptomatic";
          }
          _isFinalOut = true;
          await addRecord();
        }
    }else{
      if(coughResult != ""){
        if(coughResult == "Healthy"){
          finalHealth = "Healthy";
        }else if(coughResult == "COVID-19"){
          finalHealth = "COVID-19";
        }
        _isFinalOut = true;
        await addRecord();
      }
    }
    print("Final" + finalHealth);
    print("Cough" + coughResult);
    print("Health Data" + healthDResult);


  }

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
      _displayTextCough = 'Recording started.';
      _textColorCough = Color.fromRGBO(117, 117, 117, 1.0);
    });
    final directory = await getApplicationDocumentsDirectory();
    final fileLocation = '${directory.path}/audio.wav';
    await recorder.startRecorder(toFile: fileLocation, codec: Codec.pcm16WAV);
    // _result = "";
  }

  Future stopRecorder() async {
    setState(() {
      _isLoadingCough = false;
      _displayTextCough = "Recording stopped.\nConnecting to Server ...";
      _textColorCough = const Color.fromRGBO(65 , 161, 145, 1.0);
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
    String url = "http://192.168.10.44:8000/predict";
    // String url = "http://10.75.46.151:8000/predict";
    // String url = "http://10.40.43.166:7000/predict";

    // String url = "http://10.30.38.165:7000/predict";

    // String url = "http://10.30.38.180:7000/predict";

    var request = http.MultipartRequest('POST', Uri.parse(url));
    print("here established connection");
    final directory = await getApplicationDocumentsDirectory();
    final fileLocation = '${directory.path}/audio.wav';
    final file = File(fileLocation);
    setState(() {
      _isLoadingCough = true;
      _displayTextCough = "Waiting for Server\nto analyze cough ...";
      _textColorCough = const Color.fromRGBO(65 , 161, 145, 1.0);
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
              coughResult = "Healthy";
              _displayTextCough = "";
              _textColorCough = const Color.fromRGBO(65 , 161, 145, 1.0);
              checkResults();
            } else if (result.toString() == "1") {
              coughResult = "COVID-19";
              _displayTextCough = "";
              _textColorCough = const Color.fromRGBO(229, 127, 132, 1.0);
              checkResults();
            } else {
              retakeTest = true;
              _displayTextCough = "Please record your cough sound only.";
              _textColorCough = const Color.fromRGBO(229, 127, 132, 1.0);
            }
          });
        }
        print(result);
        print(_displayTextCough);
      } on SocketException catch (e) {
        setState(() {
          _displayTextCough = "Couldn't connect to Server";
          _textColorCough = const Color.fromRGBO(229, 127, 132, 1.0);
        });
        print('SocketException: $e');
      } on TimeoutException catch (e) {
        setState(() {
          _displayTextCough = "Couldn't connect to Server";
          _textColorCough = const Color.fromRGBO(229, 127, 132, 1.0);
        });
        print('TimeoutException: $e');
      } catch (e) {
        setState(() {
          _displayTextCough = "Couldn't connect to Server";
          _textColorCough = const Color.fromRGBO(229, 127, 132, 1.0);
        });
        print('Error: $e');
      }finally{
        setState(() {
          _isLoadingCough = false;
        });
      }

    } else {
      print("Could not locate file");
    }
  }

  Future<void> classifyHealthData() async {
    String _url = "http://192.168.10.44:8000/classify";
    // String _url = "http://10.75.46.151:8000/classify";
    // String _url = "http://10.40.38.165:7000/classify";
    // String _url = "http://10.40.43.166:7000/classify";
    // String _url = "http://10.30.38.180:7000/classify";

    setState(() {
      _isLoadingHData = true;
      _displayTextHData = "Waiting for Server\nto analyze your data ...";
      _textColorCough = const Color.fromRGBO(65 , 161, 145, 1.0);
    });

    final url = Uri.parse(_url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'body_temperature': bodytemperature.text,
      'spo2': int.parse(spo2.text),
      'heart_rate': int.parse(heartrate.text),
    });

    // Map<String, dynamic> healthData = {
    //     'body_temperature': bodytemperature.text,
    //     'spo2': int.parse(spo2.text),
    //     'heart_rate': int.parse(heartrate.text),
    // };

// Convert the Map to a JSON string
//     String jsonString = json.encode(healthData);

    try {

      final response = await http.post(url as Uri, headers: headers, body: body);

      final jsonResponse = jsonDecode(response.body);
      String result = jsonResponse['result'];
      if (result != null) {
        setState(() {
          if (result.toString() == "Healthy") {
            healthDResult = "Healthy";
            _displayTextHData = "";
            _textColorHData = const Color.fromRGBO(65 , 161, 145, 1.0);
            finishedHealthTest = true;
            checkResults();
          } else if (result.toString() == "COVID-19") {
            healthDResult = "COVID-19";
            _displayTextHData = "";
            _textColorHData = const Color.fromRGBO(229, 127, 132, 1.0);
            finishedHealthTest = true;
            checkResults();
          }
        });
      }
    } on SocketException catch (e) {
      setState(() {
        _displayTextHData = "Couldn't connect to Server";
        _textColorHData = const Color.fromRGBO(229, 127, 132, 1.0);
      });
      print('SocketException: $e');
    } on TimeoutException catch (e) {
      setState(() {
        _displayTextHData = "Couldn't connect to Server";
        _textColorHData = const Color.fromRGBO(229, 127, 132, 1.0);
      });
      print('TimeoutException: $e');
    } catch (e) {
      setState(() {
        _displayTextHData = "Couldn't connect to Server";
        _textColorHData = const Color.fromRGBO(229, 127, 132, 1.0);
      });
      print('Error: $e');
    }finally{
      setState(() {
        _isLoadingHData = false;
      });
    }
  }

  void connect() async {
    List<BluetoothService> services;
    if(isConnected){
      return;
    }

    setState(() {
      isConnected = true;
    });

    if(_device?.state == BluetoothDeviceState.connected){
      return;
    }

    List<ScanResult> scanResults = await flutterBlue?.startScan(
        timeout: Duration(seconds: 4));
    for (ScanResult scanResult in scanResults) {
      print("THE RESULTS ARE IN: $scanResult");
      if (scanResult.device.name == "ESP32") {
        _device = scanResult.device;
        setState(() {
          _NFCconnected = true;
          _hideHealthData = false;
          discardHealthData = false;
          connectionText = "Wristband Connected";
          NFC_instruction = "";
          _NFCConnectionColor = const Color.fromRGBO(65 , 161, 145, 1.0);
          _NFCTextInstruction_Color = const Color.fromRGBO(65 , 161, 145, 1.0);
        });
        break;
      }
    }

    if (_device == null) {
      return;
    }

    try {
      await _device?.connect();
      print('Connected to device: ${_device?.name}');

      // Discover services and characteristics of the connected device
      services = await _device!.discoverServices();

      // Set up notifications for the characteristics
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              "860a3d66-eb23-11ed-a05b-0242ac120003") {
            _tempCharacteristic = characteristic;
            await _tempCharacteristic!.setNotifyValue(true);
            _tempCharacteristic!.value.listen((value) {

              final tempValue = ByteData.sublistView(Uint8List.fromList(value)).getFloat32(0, Endian.little);
              setState(() {
                tempText = tempValue;
                String formattedValue = tempValue.toStringAsFixed(2);
                tempList.add(double.parse(formattedValue));
                if(bodytemperature.text == '-1'){
                  bodytemperature.text = tempList[0].toString();
                  print("Body Temp: ");
                  print(tempList[0].toString());
                }
                if(spo2.text != '-1' && bodytemperature.text != '-1' && heartrate.text != '-1' && counter == 0){ //
                  print("inside the if statement");
                  classifyHealthData();
                  counter=counter+1;
                }
              });
            });
          } else if (characteristic.uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            _pulseCharacteristic = characteristic;
            await _pulseCharacteristic!.setNotifyValue(true);
            _pulseCharacteristic!.value.listen((value) {
              final pulseValue = BLEDataConverter.i32.bytesToInt(value);
              setState(() {
                pulseText = pulseValue;
                if(pulseText != 4294966297 && pulseText != 0){
                  pulseList.add(pulseValue);
                  if(heartrate.text == '-1'){
                    heartrate.text = pulseList[0].toString();
                    print("Heart Rate: ");
                    print(pulseList[0].toString());
                  }
                }
                if(spo2.text != '-1' && bodytemperature.text != '-1' && heartrate.text != '-1' && counter == 0){ //
                  print("inside the if statement");
                  classifyHealthData();
                  counter=counter+1;
                }
              });
            });
          } else if (characteristic.uuid.toString() ==
              "97cba7a6-eb23-11ed-a05b-0242ac120003") {
            _spo2Characteristic = characteristic;
            await _spo2Characteristic!.setNotifyValue(true);
            _spo2Characteristic!.value.listen((value) {
              final spo2Value = BLEDataConverter.i32.bytesToInt(value);
              setState(() {
                spo2Text = spo2Value;
                if(spo2Text != 4294966297 && spo2Text != 0){
                  spo2List.add(spo2Value);
                  if(spo2.text == '-1'){
                    spo2.text = spo2List[0].toString();
                    print("Spo2: ");
                    print(spo2List[0].toString());
                  }
                  if(spo2.text != '-1' && bodytemperature.text != '-1' && heartrate.text != '-1' && counter == 0){ //
                    print("inside the if statement");
                    classifyHealthData();
                    counter=counter+1;
                  }
                }
              });
            });
          }
        }

      }
    } catch (e) {
      print('Error connecting to device: $e');
    }

  }

  void disconnect() {
    if (_device != null) {
      String deviceName = _device!.name ?? 'unknown device';
      print('Disconnected from $deviceName');
      _device!.disconnect();
    }
    setState(() {
      isConnected = false;
      if(_NFCconnected){
        _NFCconnected = false;
        connectionText = "Wristband Not Connected";
        NFC_instruction = "Press the button to connect.";
        _NFCConnectionColor = const Color.fromRGBO(229, 127, 132, 1.0);
        _NFCTextInstruction_Color = const Color.fromRGBO(229, 127, 132, 1.0);
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    String connectedDeviceName = _device?.name ?? '...'; // Default value if device is not connected
    String connectionStatus = isConnected ? 'Connected to device $connectedDeviceName' : 'Disconnected from $connectedDeviceName';

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

        body:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: !_isFinalOut
                    ?
                Text(
                  "The test consists of two parts:\n1. Recording your Cough Sound\n2. Reading your Biometric Data\nThe final result will be displayed after\nboth parts are completed.",
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(117, 117, 117, 1.0),
                      wordSpacing: 1.2
                  ),
                  textAlign: TextAlign.center,
                ):
                _hideHealthData ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          const Text(
                              "Cough Test Result: ",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(47, 80, 97, 1.0)
                            ),
                          ),
                          Text(
                            coughResult,
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: coughResult == "Healthy" ? const Color.fromRGBO(65 , 161, 145, 1.0) : const Color.fromRGBO(229, 127, 132, 1.0) ,
                            ),
                          ),
                        ]
                    ),
                    const Text(
                      "Your Final Result is based on Cough Test only!",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(251 , 192, 145, 1.0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          const Text(
                              "Based on your test results, you are: ",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(47, 80, 97, 1.0)
                            ),
                          ),
                          Text(
                            finalHealth,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: coughResult == "Healthy" ? const Color.fromRGBO(65 , 161, 145, 1.0) : const Color.fromRGBO(229, 127, 132, 1.0) ,
                            ),
                          ),
                          Text(
                            finalHealth == "COVID-19" ? "It is best to get checked up." : "",
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(47, 80, 97, 1.0)
                            ),
                          )
                        ]
                    ),
                  ],
                ) :
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        const Text(
                          "Cough Test Result: ",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(47, 80, 97, 1.0)
                          ),
                        ),
                        Text(
                          coughResult,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: coughResult == "Healthy" ? const Color.fromRGBO(65 , 161, 145, 1.0) : const Color.fromRGBO(229, 127, 132, 1.0) ,
                          ),
                        ),
                      ]
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          const Text(
                              "Health Data Test Result: ",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(47, 80, 97, 1.0)
                            ),
                          ),
                          Text(
                            healthDResult,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: healthDResult == "Healthy" ? const Color.fromRGBO(65 , 161, 145, 1.0) : const Color.fromRGBO(229, 127, 132, 1.0)
                            ),
                          ),
                        ]
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          const Text(
                              "Based on your test results, you are: \n",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(47, 80, 97, 1.0)
                            ),
                          ),
                          Text(
                              finalHealth,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: finalHealth == "Healthy" ? const Color.fromRGBO(65 , 161, 145, 1.0) : finalHealth == "Symptomatic" ? const Color.fromRGBO(251 , 192, 145, 1.0) : const Color.fromRGBO(229, 127, 132, 1.0) ,
                            ),
                          )
                        ]
                    ),
                    Text(
                      finalHealth == "COVID-19" ? "It is best to get checked up." : finalHealth == "Symptomatic"? "It is best to be cautious\nand do a checkup." : "",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(47, 80, 97, 1.0)
                      ),
                    ),
                  ],
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
                                  child: _isLoadingCough
                                      ?
                                  Column(
                                    children: [
                                      CircularProgressIndicator(color: Color.fromRGBO(65 , 161, 145, 1.0),),
                                      Text(
                                        _displayTextCough,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: _textColorCough,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ):
                                  Text(
                                    _displayTextCough != ""? _displayTextCough : coughResult,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: _textColorCough,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),
                    ),
                    const SizedBox(height: 15),
                    Visibility(
                      visible: retakeTest,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            retakeTest = false;
                            finishedRecording = true;
                            coughResult = '';
                            _displayTextCough = "Press to start/stop recording.";
                            _textColorCough = const Color.fromRGBO(117, 117, 117, 1.0);
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
                          'Retake Cough Test',
                          style: TextStyle(
                            fontSize: 23.0,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
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
                                      ],
                                    )
                                ),
                                Visibility(
                                  visible: !_hideHealthData,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(15.0, 3, 0, 5),
                                    child:Column(
                                      children: [
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            const Text('Temp: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color.fromRGBO(117, 117, 117, 1.0))),
                                            Text('Reading: ${bodytemperature.text}', style: const TextStyle(fontSize: 16, color: Color.fromRGBO(117, 117, 117, 1.0))),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Row(
                                          children: [
                                            const Text('Pulse: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color.fromRGBO(117, 117, 117, 1.0))),
                                            Text('Reading: ${heartrate.text}', style: const TextStyle(fontSize: 16, color: Color.fromRGBO(117, 117, 117, 1.0)))
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Row(
                                          children: [
                                            const Text('SpO2: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color.fromRGBO(117, 117, 117, 1.0))),
                                            Text('Reading: ${spo2.text}', style: const TextStyle(fontSize: 16, color: Color.fromRGBO(117, 117, 117, 1.0))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ),
                                Center(
                                  child: _isLoadingHData
                                      ?
                                  Column(
                                    children: [
                                      CircularProgressIndicator(color: Color.fromRGBO(65 , 161, 145, 1.0),),
                                      Text(
                                        _displayTextHData,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: _textColorHData,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ):
                                  Visibility(
                                    visible: !_hideHealthData,
                                    child: Text(
                                        _displayTextHData != ''? _displayTextHData : healthDResult,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: _textColorHData,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  )
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Visibility(
                                  visible: !_hideHealthData,
                                  child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color.fromRGBO(65, 161, 145, 1.0),
                                        // fixedSize: const Size(
                                        //   110,
                                        //   40,
                                        // ),
                                        elevation: 7,
                                        minimumSize: Size(130, 40),
                                        textStyle: TextStyle(fontSize: 17),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          // side: const BorderSide(
                                          //   color: Color(0xFFF4EAE6),
                                          // ),
                                        ),
                                      ),
                                      onPressed: isConnected ? null : connect,
                                      child: Text('Connect'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color.fromRGBO(47, 80, 97, 1.0),
                                        // fixedSize: const Size(
                                        //   110,
                                        //   40,
                                        // ),
                                        elevation: 7,
                                        minimumSize: Size(130, 40),
                                        textStyle: TextStyle(fontSize: 17),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          // side: const BorderSide(
                                          //   color: Color(0xFFF4EAE6),
                                          // ),
                                        ),
                                      ),
                                      onPressed: isConnected ? disconnect : null,
                                      child: Text('Disconnect'),
                                    ),
                                  ],
                                ),
                                ),
                              ],
                            ),
                          )
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Visibility(
                    //   visible: !finishedHealthTest,
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       setState(() {
                    //         finishedHealthTest = true;
                    //         counter = 0;
                    //         _displayTextHData = "";
                    //         _textColorHData = const Color.fromRGBO(117, 117, 117, 1.0);
                    //         spo2List = [];
                    //         pulseList = [];
                    //         tempList = [];
                    //       });
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor:
                    //       const Color.fromRGBO(47, 80, 97, 1.0), // Set the button's background color
                    //       minimumSize: const Size(
                    //         150,
                    //         50,
                    //       ), // Set the button's minimum dimensions
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius:
                    //         BorderRadius.circular(15), // Set the border radius
                    //       ),
                    //     ),
                    //     child: const Text(
                    //       'Retake Health Data Test',
                    //       style: TextStyle(
                    //         fontSize: 23.0,
                    //         // fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Visibility(
                  visible: !_hideHealthData && finishedHealthTest == false,
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
                              checkResults();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
              ),
              // Card(
              //     margin: const EdgeInsets.symmetric(
              //       vertical: 5,
              //       horizontal: 15,
              //     ),
              //     elevation: 7,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20.0),
              //     ),
              //     color: const Color(0xFFFFFFFF),
              //     child: SizedBox(
              //       width: 350,
              //       child: Padding(
              //         padding: const EdgeInsets.fromLTRB(
              //             5.0, 10.0, 5.0, 10.0),
              //         child: SingleChildScrollView(
              //           child: Column(
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               ListTile(
              //                 title: Text(connectionStatus),
              //               ),
              //               ListTile(
              //                 title: Text('Temp'),
              //                 subtitle: Text('Reading: $tempText'),
              //               ),
              //               ListTile(
              //                 title: Text('Pulse'),
              //                 subtitle: Text('Reading: $pulseText'),
              //               ),
              //               ListTile(
              //                 title: Text('SpO2'),
              //                 subtitle: Text('Reading: $spo2Text'),
              //               ),
              //               ButtonBar(
              //                 children: [
              //                   ElevatedButton(
              //                     onPressed: isConnected ? null : connect,
              //                     child: Text('Connect'),
              //                   ),
              //                   ElevatedButton(
              //                     onPressed: isConnected ? disconnect : null,
              //                     child: Text('Disconnect'),
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     )),
            ],
          ),
        )
    );
  }


  @override
  void dispose() {
    counter = 0;
    disconnect();
    setState(() {
      spo2List.clear();
      tempList.clear();
      pulseList.clear();
      // bodytemperature.text = "-1";
      // spo2.text = "-1";
      // heartrate.text = "-1";
    });
    recorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }
}
