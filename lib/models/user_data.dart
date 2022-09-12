import '/utils/network_util.dart';
import '/utils/custom_exception.dart';
import '/utils/api_response.dart';

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

class RequestUser {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/profile';
  static final getUserURL = baseURL + "/get";
  static final updateUserURL = baseURL + "/update";
  static final changePasswordURL = baseURL + "/changepass";
  static final appLinkURL = baseURL + "/applink";

  Future<User> getUserDetails(String user) async {
    return _netUtil
        .post(getUserURL, body: {"user_id": user}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return User.fromJson(res['profile']);
    });
  }

  Future<User> updateUser(String user_id, String name, String address,
      String city, String mobile) async {
    return _netUtil.post(updateUserURL, body: {
      "user_id": user_id,
      "user_name": name,
      "mobile_no": mobile,
      "city": city,
      "address": address
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return User.fromJson(res['user']);
    });
  }

  Future<ResponseDataAPI> changePassword(
      String email, String oldPassword, String newPassword) async {
    return _netUtil.post(changePasswordURL, body: {
      "user_id": email,
      "old_password": oldPassword,
      "new_password": newPassword
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }

  Future<String> getAppLink(bool isIOS) async {
    String os;
    if (isIOS) {
      os = "ios";
    } else {
      os = "android";
    }
    return _netUtil.post(appLinkURL, body: {"os": os}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
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
  void onPasswordUpdateSuccess(String message);
  void onPasswordUpdateError(String errorString);
}

class UserUpdatePresenter {
  UserUpdateContract _view;
  RequestUser api = new RequestUser();
  UserUpdatePresenter(this._view);

  doUpdateUser(String user_id, String name, String address, String city,
      String mobile) async {
    try {
      User user = await api.updateUser(user_id, name, address, city, mobile);
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
      var data = await api.changePassword(email, oldPassword, newPassword);
      if (data == null) {
        _view.onPasswordUpdateError("Update Failed");
      } else {
        _view.onPasswordUpdateSuccess(data.message!);
      }
    } on Exception catch (error) {
      _view.onPasswordUpdateError(error.toString());
    }
  }
}
