import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nav_app/controller/controller.dart';
import 'package:nav_app/views/home.dart';
import 'package:nav_app/views/profile.dart';
import 'package:nav_app/views/stats.dart';
import 'package:nav_app/views/takeTest.dart';
import 'package:nav_app/views/splash.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final controller = Get.put(NavBarController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavBarController>(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Virush'),
          backgroundColor: Colors.teal,
        ),
        body: IndexedStack(
          index: controller.tabIndex,
          children: const [
            Profile(),
            Home(),
            Statistics(),
            //Splash(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blueGrey[50],
          selectedItemColor: Colors.red[400],
          unselectedItemColor: Colors.blueGrey,
          currentIndex: controller.tabIndex,
          onTap: controller.changeTabIndex,
          items: [
            _bottombarItem(Icons.person, "Profile"),
            _bottombarItem(Icons.home, "Home"),
            _bottombarItem(Icons.pie_chart, "Statistics"),
            //_bottombarItem(Icons.alarm, "Splash"),
          ],
        ),
      );
    });
  }
}

_bottombarItem(IconData icon, String label) {
  return BottomNavigationBarItem(icon: Icon(icon), label: label);
}
