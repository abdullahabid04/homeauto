import 'package:flutter/material.dart';
import '/home.dart';
import 'constants/colors.dart';
import '/login_signup/login.dart';
import '/login_signup/signup.dart';
import '/screens/splashscreen/splash_screen.dart';

class HomeAutomationSplashScreen extends StatefulWidget {
  @override
  _HomeAutomationSplashScreenState createState() =>
      new _HomeAutomationSplashScreenState();
}

class _HomeAutomationSplashScreenState
    extends State<HomeAutomationSplashScreen> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(title: "Home AutoMation");
  }
}
