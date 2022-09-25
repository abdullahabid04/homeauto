import '/utils/network_util.dart';
import '/utils/custom_exception.dart';
import '/utils/api_response.dart';

class DeviceData {
  int? status;
  String? message;
  int? total;
  List<Devices>? devices;

  DeviceData({this.status, this.message, this.total, this.devices});

  DeviceData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['devices'] != null) {
      devices = <Devices>[];
      json['devices'].forEach((v) {
        devices!.add(new Devices.fromJson(v));
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

class Devices {
  String? id;
  String? userId;
  String? homeId;
  String? roomId;
  String? deviceId;
  String? deviceName;
  String? deviceType;
  String? dateCreated;

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

class RequestDevice {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/device';
  static final createDeviceURL = baseURL + "/add";
  static final getDeviceURL = baseURL + "/get";
  static final updateDeviceURL = baseURL + "/rename";
  static final deleteURL = baseURL + "/remove";

  Future<DeviceData> getDevices(String user) async {
    return _netUtil
        .post(getDeviceURL, body: {"user_id": user}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return DeviceData.fromJson(res);
    });
  }

  Future<ResponseDataAPI> updateDevices(
      String user_id, String device_id, String device_name) async {
    return _netUtil.post(updateDeviceURL, body: {
      "user_id": user_id,
      "device_id": device_id,
      "device_name": device_name
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }

  Future<ResponseDataAPI> deleteDevice(String user_id, String device_id) async {
    return _netUtil.post(deleteURL,
        body: {"user_id": user_id, "device_id": device_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }

  Future<ResponseDataAPI> createDevice(
      String user_id,
      String home_id,
      String room_id,
      String device_id,
      String device_name,
      String device_type) async {
    return _netUtil.post(createDeviceURL, body: {
      "user_id": user_id,
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
}

abstract class DeviceContract {
  void onDeviceSuccess(DeviceData userDetails);
  void onDeviceError();
}

class DevicePresenter {
  DeviceContract _view;
  RequestDevice api = new RequestDevice();
  DevicePresenter(this._view);

  doGetDevices(String user_id) async {
    try {
      var devices = await api.getDevices(user_id);
      if (devices == null) {
        _view.onDeviceError();
      } else {
        _view.onDeviceSuccess(devices);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onDeviceError();
    }
  }
}

abstract class DeviceUpdateContract {
  void onDeviceUpdateSuccess(ResponseDataAPI response);
  void onDeviceUpdateError(String errorString);
  void onDeviceDeleteSuccess(ResponseDataAPI response);
  void onDeviceDeleteError(String errorString);
}

class DeviceUpdatePresenter {
  DeviceUpdateContract _view;
  RequestDevice api = new RequestDevice();
  DeviceUpdatePresenter(this._view);

  doUpdateDevice(String user_id, String device_id, String device_name) async {
    try {
      ResponseDataAPI user =
          await api.updateDevices(user_id, device_id, device_name);
      if (user == null) {
        _view.onDeviceUpdateError("Update Failed");
      } else {
        _view.onDeviceUpdateSuccess(user);
      }
    } on Exception catch (error) {
      _view.onDeviceUpdateError(error.toString());
    }
  }

  doDeleteDevice(String? user_id, String? device_id) async {
    try {
      ResponseDataAPI user = await api.deleteDevice(user_id!, device_id!);
      if (user == null) {
        _view.onDeviceDeleteError("Update Failed");
      } else {
        _view.onDeviceDeleteSuccess(user);
      }
    } on Exception catch (error) {
      _view.onDeviceDeleteError(error.toString());
    }
  }
}

abstract class CreateDeviceContract {
  void onCreateDeviceSuccess(ResponseDataAPI userDetails);
  void onCreateDeviceError();
}

class CreateDevicePresenter {
  CreateDeviceContract _view;
  RequestDevice api = new RequestDevice();
  CreateDevicePresenter(this._view);

  doCreateDevice(String user_id, String home_id, String room_id,
      String device_id, String device_name, String device_type) async {
    try {
      ResponseDataAPI user = await api.createDevice(
          user_id, home_id, room_id, device_id, device_name, device_type);
      if (user == null) {
        _view.onCreateDeviceError();
      } else {
        _view.onCreateDeviceSuccess(user);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onCreateDeviceError();
    }
  }
}
