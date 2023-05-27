import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/navbar_controller.dart';
import '../views/home.dart';
import '../views/profile.dart';
import '../views/records.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final navbarController = Get.put(NavBarController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavBarController>(builder: (context) {
      return Scaffold(
        backgroundColor: Color(0xFFF4EAE6),
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
          ),
          title: const Text('Virush', style: TextStyle(fontFamily: 'Pacifico', fontSize: 25),),
          backgroundColor: const Color.fromRGBO(65 , 161, 145, 1.0),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: IndexedStack(
          index: navbarController.tabIndex,
          children: const [
            Profile(),
            Home(),
            Records(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blueGrey[50],
          selectedItemColor: Color.fromRGBO(229, 127, 132, 1.0),
          unselectedItemColor: Color.fromRGBO(47, 80, 97, 1.0),
          currentIndex: navbarController.tabIndex,
          onTap: navbarController.changeTabIndex,
          items: [
            navbarController.getBottombarItem(Icons.person, "Profile"),
            navbarController.getBottombarItem(Icons.home, "Home"),
            navbarController.getBottombarItem(
                Icons.file_copy_rounded, "Records"),
          ],
        ),
      );
    });
  }
}
