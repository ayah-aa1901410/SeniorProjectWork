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
    GetPage(name: navbar, page: () =>  NavBar()),
    GetPage(name: home, page: () =>  Home()),
    GetPage(name: profile, page: () =>  Profile()),
    GetPage(name: records, page: () =>  Records()),
    GetPage(name: takeTest, page: () => TakeTest()),
    GetPage(name: splash, page: () =>  Splash()),
    GetPage(name: signup, page: () =>  Signup()),
    GetPage(name: login, page: () =>  Login()),
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
