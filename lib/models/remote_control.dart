import '../utils/custom_exception.dart';
import '../utils/network_util.dart';

class DeviceRemoteControl {
  int? status;
  String? message;
  List<Remote>? remote;
  List<Control>? control;

  DeviceRemoteControl({this.status, this.message, this.remote, this.control});

  DeviceRemoteControl.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['remote'] != null) {
      remote = <Remote>[];
      json['remote'].forEach((v) {
        remote!.add(new Remote.fromJson(v));
      });
    }
    if (json['control'] != null) {
      control = <Control>[];
      json['control'].forEach((v) {
        control!.add(new Control.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.remote != null) {
      data['remote'] = this.remote!.map((v) => v.toJson()).toList();
    }
    if (this.control != null) {
      data['control'] = this.control!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Remote {
  String? id;
  String? deviceId;
  String? portId;
  String? portName;

  Remote({this.id, this.deviceId, this.portId, this.portName});

  Remote.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceId = json['device_id'];
    portId = json['port_id'];
    portName = json['port_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['device_id'] = this.deviceId;
    data['port_id'] = this.portId;
    data['port_name'] = this.portName;
    return data;
  }
}

class Control {
  String? id;
  String? deviceId;
  String? portId;
  String? portStatus;

  Control({this.id, this.deviceId, this.portId, this.portStatus});

  Control.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceId = json['device_id'];
    portId = json['port_id'];
    portStatus = json['port_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['device_id'] = this.deviceId;
    data['port_id'] = this.portId;
    data['port_status'] = this.portStatus;
    return data;
  }
}

class RequestRemote {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/specs';
  static final getRemoteURL = baseURL + "/get";

  Future<DeviceRemoteControl> getremote(String device_id) async {
    return _netUtil
        .post(getRemoteURL, body: {"device_id": device_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return DeviceRemoteControl.fromJson(res);
    });
  }
}

abstract class DeviceRemoteControlContract {
  void onDeviceRemoteSuccess(DeviceRemoteControl remoteControl);
  void onDeviceRemoteError();
}

class DeviceRemoteControlPresenter {
  DeviceRemoteControlContract _view;
  RequestRemote api = new RequestRemote();
  DeviceRemoteControlPresenter(this._view);

  doGetRemote(String device_id) async {
    try {
      var devices = await api.getremote(device_id);
      if (devices == null) {
        _view.onDeviceRemoteError();
      } else {
        _view.onDeviceRemoteSuccess(devices);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onDeviceRemoteError();
    }
  }
}
