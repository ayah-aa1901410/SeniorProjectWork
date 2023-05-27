import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBarController extends GetxController {
  var tabIndex = 1;
  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }

  getBottombarItem(IconData icon, String label) {
    return BottomNavigationBarItem(icon: Icon(icon), label: label);
  }
}
