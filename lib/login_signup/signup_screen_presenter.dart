import 'dart:async';
import '/utils/network_util.dart';
import '/utils/custom_exception.dart';

class SignUpData {
  int? status;
  String? message;
  String? userId;
  int? code;
  User? user;

  SignUpData({this.status, this.message, this.userId, this.code, this.user});

  SignUpData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
    code = json['code'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['user_id'] = this.userId;
    data['code'] = this.code;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? userId;
  String? userName;
  String? eMail;
  String? mobileNo;
  String? password;
  String? city;
  String? address;
  String? dateCreated;

  User(
      {this.id,
      this.userId,
      this.userName,
      this.eMail,
      this.mobileNo,
      this.password,
      this.city,
      this.address,
      this.dateCreated});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    eMail = json['e_mail'];
    mobileNo = json['mobile_no'];
    password = json['password'];
    city = json['city'];
    address = json['address'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['e_mail'] = this.eMail;
    data['mobile_no'] = this.mobileNo;
    data['password'] = this.password;
    data['city'] = this.city;
    data['address'] = this.address;
    data['date_created'] = this.dateCreated;
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

  Future<SignUpData> signup(String name, String email, String password,
      String address, String city, String contact) {
    return _netUtil.post(signupURL, body: {
      "user_name": name,
      "e_mail": email,
      "password": password,
      "address": address,
      "city": city,
      "mobile_no": contact,
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0)
        throw new FormException(res["message"].toString());
      return SignUpData.fromJson(res);
    });
  }
}

abstract class SignupScreenContract {
  void onSignupSuccess(var res);
  void onSignupError(String errorTxt);
}

class SignupScreenPresenter {
  SignupScreenContract _view;
  RestDatasource api = new RestDatasource();
  SignupScreenPresenter(this._view);

  doSignup(String name, String email, String password, String address,
      String city, String contact) async {
    try {
      var res = await api.signup(name, email, password, address, city, contact);
      _view.onSignupSuccess(res);
    } on Exception catch (error) {
      _view.onSignupError(error.toString());
    }
  }
}
