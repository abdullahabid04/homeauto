import 'package:flutter/material.dart';
import '../../models/user_data.dart';

class ReferProgram extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  const ReferProgram({Key? key, this.user, this.callbackUser})
      : super(key: key);

  @override
  State<ReferProgram> createState() => _ReferProgramState();
}

class _ReferProgramState extends State<ReferProgram> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
