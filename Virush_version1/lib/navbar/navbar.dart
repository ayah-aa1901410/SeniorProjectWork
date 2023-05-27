import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/navbar_controller.dart';
import '../views/home.dart';
import '../views/profile.dart';
import '../views/records.dart';

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
        appBar: AppBar(
          title: const Text('Virush'),
          backgroundColor: Colors.teal,
          automaticallyImplyLeading: false,
          // actions: (navbarController.tabIndex != 0)
          //     ? null
          //     : <Widget>[
          //         ElevatedButton.icon(
          //           label: Text("Log out"),
          //           icon: const Icon(Icons.logout),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.red[400],
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 20, vertical: 10),
          //           ),
          //           onPressed: () {
          //             navbarController.signOut(context);
          //           },
          //         ),
          //       ],
        ),
        body: IndexedStack(
          index: navbarController.tabIndex,
          children: const [
            Profile(),
            Home(),
            Records(),
            //Splash(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blueGrey[50],
          selectedItemColor: Colors.red[400],
          unselectedItemColor: Colors.blueGrey,
          currentIndex: navbarController.tabIndex,
          onTap: navbarController.changeTabIndex,
          items: [
            navbarController.getBottombarItem(Icons.person, "Profile"),
            navbarController.getBottombarItem(Icons.home, "Home"),
            navbarController.getBottombarItem(
                Icons.file_copy_rounded, "Records"),
            //_bottombarItem(Icons.alarm, "Splash"),
          ],
        ),
      );
    });
  }
}
