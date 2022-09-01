import '/utils/network_util.dart';
import '/utils/custom_exception.dart';

class DeviceData {
  int status;
  String message;
  int total;
  List<Devices> devices;

  DeviceData({this.status, this.message, this.total, this.devices});

  DeviceData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['devices'] != null) {
      devices = <Devices>[];
      json['devices'].forEach((v) {
        devices.add(new Devices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.devices != null) {
      data['devices'] = this.devices.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Devices {
  String id;
  String userId;
  String homeId;
  String roomId;
  String deviceId;
  String deviceName;
  String deviceType;
  String dateCreated;

  Devices(
      {this.id,
      this.userId,
      this.homeId,
      this.roomId,
      this.deviceId,
      this.deviceName,
      this.deviceType,
      this.dateCreated});

  Devices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    homeId = json['home_id'];
    roomId = json['room_id'];
    deviceId = json['device_id'];
    deviceName = json['device_name'];
    deviceType = json['device_type'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['home_id'] = this.homeId;
    data['room_id'] = this.roomId;
    data['device_id'] = this.deviceId;
    data['device_name'] = this.deviceName;
    data['device_type'] = this.deviceType;
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

  Future<DeviceData> getUserDetails(String user) async {
    return _netUtil
        .post(getUserURL, body: {"user_id": user}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return DeviceData.fromJson(res);
    });
  }

  Future<DeviceData> updateUser(String email, String name, String address,
      String city, String mobile) async {
    return _netUtil.post(updateUserURL, body: {
      "user_id": email,
      "user_name": name,
      "mobile_no": mobile,
      "city": city,
      "adddress": address
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return DeviceData.fromJson(res);
    });
  }

  Future<DeviceData> changePassword(
      String email, String oldPassword, String newPassword) async {
    return _netUtil.post(changePasswordURL, body: {
      "user_id": email,
      "old_password": oldPassword,
      "new_password": newPassword
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return DeviceData.fromJson(res);
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
  void onUserSuccess(DeviceData userDetails);
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
  void onUserUpdateSuccess(DeviceData userDetails);
  void onUserUpdateError(String errorString);
}

class UserUpdatePresenter {
  UserUpdateContract _view;
  RequestUser api = new RequestUser();
  UserUpdatePresenter(this._view);

  doUpdateUser(String email, String name, String address, String city,
      String mobile) async {
    try {
      DeviceData user =
          await api.updateUser(email, name, address, city, mobile);
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
      DeviceData user =
          await api.changePassword(email, oldPassword, newPassword);
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
