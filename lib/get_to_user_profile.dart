import 'package:flutter/material.dart';
import '/show_user.dart';
import '/models/user_data.dart';

class GoToUserProfile {
  final User user;
  final Function callbackThis;
  final bool isIOS;
  final BuildContext context;
  GoToUserProfile({this.context, this.isIOS, this.user, this.callbackThis});
  Widget showUser() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowUser(
              user: this.user,
              callbackUser: this.callbackThis,
            ),
          ),
        );
      },
      icon: Icon(Icons.person),
    );
  }
}
