import 'package:flutter/material.dart';
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
