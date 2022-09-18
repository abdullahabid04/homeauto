import 'package:is_first_run/is_first_run.dart';

class CheckAppFirstRun {
  static Future<bool> check() {
    Future<bool> status = IsFirstRun.isFirstRun();
    return status;
  }
}
