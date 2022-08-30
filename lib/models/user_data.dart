import '/utils/network_util.dart';
import '/utils/custom_exception.dart';

class User {
  int _id;
  String _email,
      _password,
      _name,
      _city,
      _address,
      _mobile,
      _userid,
      _datecreated;
  User(this._id, this._email, this._password, this._name, this._city,
      this._mobile, this._address, this._userid, this._datecreated);

  User.map(dynamic obj) {
    this._id = int.parse(obj['id'].toString());
    this._userid = obj["user_id"];
    this._name = obj["user_name"];
    this._email = obj["e_mail"];
    this._mobile = obj["mobile_no"];
    this._password = obj["password"];
    this._city = obj["city"];
    this._address = obj["address"];
    this._datecreated = obj['date_created'];
  }
  int get id => _id;
  String get userid => _userid;
  String get name => _name;
  String get email => _email;
  String get mobile => _mobile;
  String get password => _password;
  String get city => _city;
  String get address => _address;
  String get datecreated => _datecreated;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = _id;
    map['user_id'] = _userid;
    map["user_name"] = _name;
    map["e_mail"] = _email;
    map["mobile_no"] = _mobile;
    map["password"] = _password;
    map["city"] = _city;
    map["address"] = _address;
    map['date_created'] = _datecreated;
    return map;
  }

  @override
  String toString() {
    return "User $name";
  }
}

class RequestUser {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'https://homeautomations.tk/brijesh/server_files';
  static final finalURL = baseURL + "/user_actions.php";
  // static final db = new DatabaseHelper();
  Future<User> getUserDetails(String user) async {
    return _netUtil.post(finalURL, body: {"email": user, "action": "1"}).then(
        (dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      return User.map(res['user']);
    });
  }

  Future<User> updateUser(String email, String name, String address,
      String city, String mobile) async {
    return _netUtil.post(finalURL, body: {
      "email": email,
      "name": name,
      "address": address,
      "city": city,
      "mobile": mobile,
      "action": "2"
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      return User.map(res['user']);
    });
  }

  Future<User> changePassword(
      String email, String oldPassword, String newPassword) async {
    return _netUtil.post(finalURL, body: {
      "email": email,
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "action": "3"
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res['errorMessage']);
      return User.map(res['user']);
    });
  }

  Future<String> getAppLink(bool isIOS) async {
    String os;
    if (isIOS) {
      os = "true";
    } else {
      os = "false";
    }
    return _netUtil.post(finalURL, body: {
      "action": "4",
      "isIOS": os,
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res['errorMessage']);
      return res['link'];
    });
  }
}

abstract class UserContract {
  void onUserSuccess(User userDetails);
  void onUserError();
}

class UserPresenter {
  UserContract _view;
  RequestUser api = new RequestUser();
  UserPresenter(this._view);

  doGetUser(String userEmail) async {
    try {
      var user = await api.getUserDetails(userEmail);
      if (user == null) {
        _view.onUserError();
      } else {
        _view.onUserSuccess(user);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onUserError();
    }
  }
}

abstract class UserUpdateContract {
  void onUserUpdateSuccess(User userDetails);
  void onUserUpdateError(String errorString);
}

class UserUpdatePresenter {
  UserUpdateContract _view;
  RequestUser api = new RequestUser();
  UserUpdatePresenter(this._view);

  doUpdateUser(String email, String name, String address, String city,
      String mobile) async {
    try {
      User user = await api.updateUser(email, name, address, city, mobile);
      if (user == null) {
        _view.onUserUpdateError("Update Failed");
      } else {
        _view.onUserUpdateSuccess(user);
      }
    } on Exception catch (error) {
      _view.onUserUpdateError(error.toString());
    }
  }

  doChangePassword(String email, String oldPassword, String newPassword) async {
    try {
      User user = await api.changePassword(email, oldPassword, newPassword);
      if (user == null) {
        _view.onUserUpdateError("Update Failed");
      } else {
        _view.onUserUpdateSuccess(user);
      }
    } on Exception catch (error) {
      _view.onUserUpdateError(error.toString());
    }
  }
}
