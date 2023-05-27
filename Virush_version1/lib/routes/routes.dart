import 'package:get/get.dart';

import '/navbar/navbar.dart';
import '/views/home.dart';
import '/views/login.dart';
import '/views/profile.dart';
import '/views/signup.dart';
import '/views/records.dart';
import '/views/takeTest.dart';
import '../views/splash.dart';

class AppPage {
  static List<GetPage> routes = [
    GetPage(name: navbar, page: () => const NavBar()),
    GetPage(name: home, page: () => const Home()),
    GetPage(name: profile, page: () => const Profile()),
    GetPage(name: records, page: () => const Records()),
    GetPage(name: takeTest, page: () => const TakeTest()),
    GetPage(name: splash, page: () => const Splash()),
    GetPage(name: signup, page: () => const Signup()),
    GetPage(name: login, page: () => const Login()),
  ];

  static getnavbar() => navbar;
  static gethome() => home;
  static getprofile() => profile;
  static getrecords() => records;
  static gettakeTest() => takeTest;
  static getsplash() => splash;
  static getlogin() => login;
  static getsignup() => signup;

  //

  static String navbar = '/';
  static String home = '/home';
  static String profile = '/profile';
  static String records = '/records';
  static String takeTest = '/takeTest';
  static String splash = '/splash';
  static String login = '/login';
  static String signup = '/signup';
}
