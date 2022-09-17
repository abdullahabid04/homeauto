import 'package:is_first_run/is_first_run.dart';

class CheckAppFirstRun {
  late bool status;
  Future<bool> check() async {
    status = await IsFirstRun.isFirstRun();
    return status;
  }
}
