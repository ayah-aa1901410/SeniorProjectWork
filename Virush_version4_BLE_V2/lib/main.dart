import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Tinos-Bold',
            ),
            getPages: AppPage.routes,
            initialRoute: AppPage.getsplash(),
          );
        } else {
          return MaterialApp(
            home: Scaffold(
              body: Column(
                children: const [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
