import 'package:flutter/material.dart';
import '/userpreferances/user_preferances.dart';
import '/app.dart';
import 'home.dart';
import 'login_signup/login.dart';
import 'login_signup/signup.dart';
import '/themes/my_app_theme.dart';
import '/constants/routes.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await UserSharedPreferences.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Automation',
      theme: MyAppTheme.getTheme(),
      initialRoute: initialRoute,
      routes: {
        initialRoute: (context) => HomeAutomationSplashScreen(),
        loginRoute: (context) => LoginScreen(),
        registerRoute: (context) => SignupScreen(),
        homeRoute: (context) => HomeScreen(),
      },
    );
  }
}
