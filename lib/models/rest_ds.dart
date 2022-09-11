import 'dart:async';
import '/utils/network_util.dart';
import '/models/user_data.dart';
import '/utils/custom_exception.dart';

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

  Future<Map> signup(String name, String email, String password, String address,
      String city, String contact) {
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
      return res;
    });
  }
}
