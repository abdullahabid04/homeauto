import '/models/user_data.dart';
import 'dart:async';
import '/utils/network_util.dart';
import '/utils/custom_exception.dart';

class LogInData {
  int? status;
  String? message;
  String? userId;
  int? code;

  LogInData({this.status, this.message, this.userId, this.code});

  LogInData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['user_id'] = this.userId;
    data['code'] = this.code;
    return data;
  }
}

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/user';
  static final loginURL = baseURL + "/login";
  static final signupURL = baseURL + "/signup";

  Future<User> login(String contact, String password) {
    return _netUtil.post(loginURL,
        body: {"mobile_no": contact, "password": password}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0)
        throw new FormException(res["message"].toString());
      return new User.fromJson(res["user"]);
    });
  }

  Future<LogInData> signup(String name, String email, String password,
      String address, String city, String contact) {
    return _netUtil.post(signupURL, body: {
      "user_name": name,
      "e_mail": email,
      "password": password.toString(),
      "address": address,
      "city": city,
      "mobile_no": contact.toString(),
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0)
        throw new FormException(res["message"].toString());
      return LogInData.fromJson(res);
    });
  }
}

abstract class LoginScreenContract {
  void onLoginSuccess(User user);
  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  RestDatasource api = new RestDatasource();
  LoginScreenPresenter(this._view);

  doLogin(String email, String password) async {
    try {
      var user = await api.login(email, password);
      _view.onLoginSuccess(user);
    } on Exception catch (error) {
      _view.onLoginError(error.toString());
    }
  }
}
