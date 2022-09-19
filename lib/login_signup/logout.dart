import 'package:last_home_auto/userpreferances/user_preferances.dart';
import 'package:flutter/material.dart';

class GetLogOut {
  logout(BuildContext context) async {
    await UserSharedPreferences.setLoggedInStatus(false);
    Navigator.pushNamed(context, '/login');
  }
}
