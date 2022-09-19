import 'package:flutter/material.dart';

import '../constants/colors.dart';

class MyAppTheme {
  static ThemeData getTheme() {
    return _kHomeAutomationTheme;
  }
}

final ThemeData _kHomeAutomationTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: kHAutoBlue900,
    primaryColor: kHAutoBlue100,
    buttonColor: kHAutoBlue100,
    scaffoldBackgroundColor: kHAutoBackgroundWhite,
    cardColor: kHAutoBackgroundWhite,
    textSelectionColor: kHAutoBlue100,
    errorColor: kShrineErrorRed,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: kHAutoBlue100,
      textTheme: ButtonTextTheme.normal,
    ),
    primaryIconTheme: base.iconTheme.copyWith(color: kHAutoBlue900),
    textTheme: _buildAppTextTheme(base.textTheme),
    primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildAppTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildAppTextTheme(TextTheme base) {
  return base
      .copyWith(
        headline1: base.headline1!.copyWith(
          fontWeight: FontWeight.w500,
        ),
        subtitle1: base.headline6!.copyWith(fontSize: 18.0),
        caption: base.caption!.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
        bodyText2: base.bodyText1!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
      )
      .apply(
        fontFamily: 'Raleway',
        displayColor: kHAutoBlue900,
        bodyColor: kHAutoBlue900,
      );
}
