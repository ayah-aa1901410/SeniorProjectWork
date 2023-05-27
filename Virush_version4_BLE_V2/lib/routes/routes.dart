import 'package:get/get.dart';

import '/navbar/navbar.dart';
import '/view/home.dart';
import '/view/login.dart';
import '/view/profile.dart';
import '/view/signup.dart';
import '/view/records.dart';
import '/view/takeTest.dart';
import '/view/splash.dart';

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
