import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nav_app/routes/routes.dart';

void main() {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Tinos-Bold',
    ),
    initialRoute: AppPage.getnavbar(),
    getPages: AppPage.routes,
  ));
}
