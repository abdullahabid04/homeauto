import '../utils/custom_exception.dart';
import '../utils/network_util.dart';
import '/utils/api_response.dart';

class DeviceInfo {
  int? status;
  String? message;
  int? total;
  List<Info>? info;

  DeviceInfo({this.status, this.message, this.total, this.info});

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['info'] != null) {
      info = <Info>[];
      json['info'].forEach((v) {
        info!.add(new Info.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.info != null) {
      data['info'] = this.info!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Info {
  String? id;
  String? userId;
  String? homeId;
  String? roomId;
  String? userRole;
  String? shared;
  String? deviceId;
  String? deviceName;
  String? active;

  Info(
      {this.id,
      this.userId,
      this.homeId,
      this.roomId,
      this.userRole,
      this.shared,
      this.deviceId,
      this.deviceName,
      this.active});

  Info.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    homeId = json['home_id'];
    roomId = json['room_id'];
    userRole = json['user_role'];
    shared = json['shared'];
    deviceId = json['device_id'];
    deviceName = json['device_name'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['home_id'] = this.homeId;
    data['room_id'] = this.roomId;
    data['user_role'] = this.userRole;
    data['shared'] = this.shared;
    data['device_id'] = this.deviceId;
    data['device_name'] = this.deviceName;
    data['active'] = this.active;
    return data;
  }
}

class RequestDeviceInfo {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/device';
  static final deviceInfoURL = baseURL + "/info";
  static final deviceShareURL = baseURL + "/share";
  static final devicePowerURL = baseURL + "/power";

  Future<DeviceInfo> getDevicesInfo(String user) async {
    return _netUtil
        .post(deviceInfoURL, body: {"user_id": user}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return DeviceInfo.fromJson(res);
    });
  }

  Future<ResponseDataAPI> shareDevice(
      String user_id,
      String shared_to_contact,
      String home_id,
      String room_id,
      String device_id,
      String device_name,
      String device_type) async {
    return _netUtil.post(deviceShareURL, body: {
      "user_id": user_id,
      "shared_to_contact": shared_to_contact,
      "home_id": home_id,
      "room_id": room_id,
      "device_id": device_id,
      "device_name": device_name,
      "device_type": device_type
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }

  Future<ResponseDataAPI> powerDevice(
      String user_id, String device_id, String device_status) async {
    return _netUtil.post(devicePowerURL, body: {
      "user_id": user_id,
      "device_id": device_id,
      "device_status": device_status
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }
}

abstract class DeviceInfoContract {
  void onDeviceInfoSuccess(DeviceInfo deviceInfo);
  void onDeviceInfoError();
  void onShareDeviceSuccess(String? message);
  void onShareDeviceError();
  void onPowerDeviceSuccess(String? message);
  void onPowerDeviceError(String? message);
}

class DeviceInfoPresenter {
  DeviceInfoContract _view;
  RequestDeviceInfo api = new RequestDeviceInfo();
  DeviceInfoPresenter(this._view);

  doGetDevicesInfo(String user_id) async {
    try {
      var devicesInfo = await api.getDevicesInfo(user_id);
      if (devicesInfo == null) {
        _view.onDeviceInfoError();
      } else {
        _view.onDeviceInfoSuccess(devicesInfo);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onDeviceInfoError();
    }
  }

  doShareDevice(
      String user_id,
      String shared_to_contact,
      String home_id,
      String room_id,
      String device_id,
      String device_name,
      String device_type) async {
    try {
      var deviceShare = await api.shareDevice(user_id, shared_to_contact,
          home_id, room_id, device_id, device_name, device_type);
      if (deviceShare == null) {
        _view.onShareDeviceError();
      } else {
        _view.onShareDeviceSuccess(deviceShare.message);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onShareDeviceError();
    }
  }

  doPowerDevice(String user_id, String device_id, String device_status) async {
    try {
      var devicePower =
          await api.powerDevice(user_id, device_id, device_status);
      if (devicePower == null) {
        _view.onPowerDeviceError(device_id);
      } else {
        _view.onPowerDeviceSuccess(device_id);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onPowerDeviceError(device_id);
    }
  }
}
