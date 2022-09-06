import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/utils/color_loader.dart';

class ShowProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: ColorLoader(
        color1: Colors.redAccent,
        color2: Colors.blue,
        color3: Colors.green,
      )),
    );
  }
}
