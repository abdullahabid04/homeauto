import 'package:flutter/material.dart';
import '/utils/color_loader.dart';

class ShowProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: ColorLoader(
        color1: Colors.red,
        color2: Colors.green,
        color3: Colors.blue,
      )),
    );
  }
}
