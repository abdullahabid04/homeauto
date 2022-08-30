import 'package:flutter/material.dart';
import '/models/user_data.dart';

class DashBoard extends StatefulWidget {
  final User user;
  final Function callbackUser;
  const DashBoard({Key key, this.user, this.callbackUser}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView();
  }
}
