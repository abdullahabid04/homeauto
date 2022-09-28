import '../utils/custom_exception.dart';
import '../utils/network_util.dart';
import '/utils/api_response.dart';

class SpecificDeviceInfo {
  int? status;
  String? message;
  int? total;
  List<SpecificInfo>? info;

  SpecificDeviceInfo({this.status, this.message, this.total, this.info});

  SpecificDeviceInfo.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['info'] != null) {
      info = <SpecificInfo>[];
      json['info'].forEach((v) {
        info!.add(new SpecificInfo.fromJson(v));
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

class SpecificInfo {
  String? id;
  String? userId;
  String? homeId;
  String? roomId;
  String? userRole;
  String? shared;
  String? deviceId;
  String? deviceName;
  String? active;

  SpecificInfo(
      {this.id,
      this.userId,
      this.homeId,
      this.roomId,
      this.userRole,
      this.shared,
      this.deviceId,
      this.deviceName,
      this.active});

  SpecificInfo.fromJson(Map<String, dynamic> json) {
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
  static final deviceInfoURL = baseURL + "/infospecifics";

  Future<SpecificDeviceInfo> getDevicesInfo(
      String user_id, String home_id, String room_id) async {
    return _netUtil.post(
      deviceInfoURL,
      body: {
        "user_id": user_id,
        "home_id": home_id,
        "room_id": room_id,
      },
    ).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return SpecificDeviceInfo.fromJson(res);
    });
  }
}

abstract class SpecificDeviceInfoContract {
  void onSpecificDeviceInfoSuccess(SpecificDeviceInfo deviceInfo);
  void onSpecificDeviceInfoError();
}

class SpecificDeviceInfoPresenter {
  SpecificDeviceInfoContract _view;
  RequestDeviceInfo api = new RequestDeviceInfo();
  SpecificDeviceInfoPresenter(this._view);

  doGetDevicesInfo(String user_id, String home_id, String room_id) async {
    try {
      var devicesInfo = await api.getDevicesInfo(user_id, home_id, room_id);
      if (devicesInfo == null) {
        _view.onSpecificDeviceInfoError();
      } else {
        _view.onSpecificDeviceInfoSuccess(devicesInfo);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onSpecificDeviceInfoError();
    }
  }
}
