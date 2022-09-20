import 'package:flutter/material.dart';

class ShowStatus {
  Widget showStatus(message) {
    return new GridView.count(
      crossAxisCount: 1,
      children: List.generate(
        1,
        (index) {
          return Container(
            child: Center(
              child: Text(message),
            ),
          );
        },
      ),
    );
  }
}
