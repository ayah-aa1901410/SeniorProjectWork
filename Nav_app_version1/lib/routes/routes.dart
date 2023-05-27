import 'package:get/get.dart';
import 'package:nav_app/controller/controller.dart';
import 'package:nav_app/navbar/navbar.dart';
import 'package:nav_app/views/home.dart';
import 'package:nav_app/views/profile.dart';
import 'package:nav_app/views/splash.dart';
import 'package:nav_app/views/stats.dart';
import 'package:nav_app/views/takeTest.dart';

class AppPage {
  static List<GetPage> routes = [
    GetPage(name: navbar, page: () => const NavBar()),
    GetPage(name: home, page: () => const Home()),
    GetPage(name: profile, page: () => const Profile()),
    GetPage(name: stats, page: () => const Statistics()),
    GetPage(name: takeTest, page: () => const TakeTest()),
    GetPage(name: splash, page: () => const Splash()),
  ];

  static getnavbar() => navbar;
  static gethome() => home;
  static getprofile() => profile;
  static getstats() => stats;
  static gettakeTest() => takeTest;
  static getsplash() => splash;

  //

  static String navbar = '/';
  static String home = '/home';
  static String profile = '/profile';
  static String stats = '/stats';
  static String takeTest = '/takeTest';
  static String splash = '/splash';
}
