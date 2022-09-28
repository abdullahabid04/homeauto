import '/utils/network_util.dart';
import '/utils/custom_exception.dart';
import '/utils/api_response.dart';

class SpecificDeviceData {
  int? status;
  String? message;
  int? total;
  List<SpcificDevices>? devices;

  SpecificDeviceData({this.status, this.message, this.total, this.devices});

  SpecificDeviceData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['devices'] != null) {
      devices = <SpcificDevices>[];
      json['devices'].forEach((v) {
        devices!.add(new SpcificDevices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.devices != null) {
      data['devices'] = this.devices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SpcificDevices {
  String? id;
  String? userId;
  String? homeId;
  String? roomId;
  String? deviceId;
  String? deviceName;
  String? deviceType;
  String? dateCreated;

  SpcificDevices(
      {this.id,
      this.userId,
      this.homeId,
      this.roomId,
      this.deviceId,
      this.deviceName,
      this.deviceType,
      this.dateCreated});

  SpcificDevices.fromJson(Map<String, dynamic> json) {
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

class RequestDevice {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/device';
  static final getDeviceURL = baseURL + "/specifics";

  Future<SpecificDeviceData> getDevices(
      String user_id, String home_id, String room_id) async {
    return _netUtil.post(
      getDeviceURL,
      body: {
        "user_id": user_id,
        "home_id": home_id,
        "room_id": room_id,
      },
    ).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return SpecificDeviceData.fromJson(res);
    });
  }
}

abstract class SpecificDeviceContract {
  void onSpecificDeviceSuccess(SpecificDeviceData userDetails);
  void onSpecificDeviceError();
}

class SpecificDevicePresenter {
  SpecificDeviceContract _view;
  RequestDevice api = new RequestDevice();
  SpecificDevicePresenter(this._view);

  doGetDevices(String user_id, String home_id, String room_id) async {
    try {
      var devices = await api.getDevices(user_id, home_id, room_id);
      if (devices == null) {
        _view.onSpecificDeviceError();
      } else {
        _view.onSpecificDeviceSuccess(devices);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onSpecificDeviceError();
    }
  }
}
