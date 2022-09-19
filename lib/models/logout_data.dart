import 'package:flutter/cupertino.dart';

import '/userpreferances/user_preferances.dart';

class UserLogOut {
  bool logout() {
    try {
      UserSharedPreferences.setLoggedInStatus(false);
      return true;
    } on Exception catch (e) {
      return false;
    }
  }
}

abstract class UserLogOutContractor {
  void onUserLogOutSucces(BuildContext context);
  void onUserLogOutError(BuildContext context);
}

class UserLogOutPresenter {
  UserLogOutContractor _contractor;
  UserLogOut api = UserLogOut();
  UserLogOutPresenter(this._contractor);

  doLogOut(BuildContext context) {
    bool status = api.logout();
    if (status) {
      _contractor.onUserLogOutSucces(context);
    } else {
      _contractor.onUserLogOutError(context);
    }
  }
}
