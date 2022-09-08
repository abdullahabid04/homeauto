import '../utils/custom_exception.dart';
import '../utils/network_util.dart';

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
  String? userRole;
  String? shared;
  String? deviceId;
  String? deviceName;
  String? active;

  Info(
      {this.id,
      this.userId,
      this.userRole,
      this.shared,
      this.deviceId,
      this.deviceName,
      this.active});

  Info.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
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
  static final DeviceInfoURL = baseURL + "/info";

  Future<DeviceInfo> getDevicesInfo(String user) async {
    return _netUtil
        .post(DeviceInfoURL, body: {"user_id": user}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return DeviceInfo.fromJson(res);
    });
  }
}

abstract class DeviceInfoContract {
  void onDeviceInfoSuccess(DeviceInfo deviceInfo);
  void onDeviceInfoError();
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
}
