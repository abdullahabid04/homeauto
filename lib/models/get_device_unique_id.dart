import '../utils/custom_exception.dart';
import '../utils/network_util.dart';

class DeviceUniqueId {
  int? status;
  String? message;
  String? deviceId;

  DeviceUniqueId({this.status, this.message, this.deviceId});

  DeviceUniqueId.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    deviceId = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['device_id'] = this.deviceId;
    return data;
  }
}

class RequestDeviceId {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/device';
  static final deviceIdURL = baseURL + "/id";

  Future<DeviceUniqueId> getDeviceuniqueId() async {
    return _netUtil.get(deviceIdURL).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return DeviceUniqueId.fromJson(res);
    });
  }
}

abstract class DeviceIdContracor {
  void onDeviceIdSuccess(String device_id);
  void onDeviceIdError(String error);
}

class DeviceIdPresenter {
  DeviceIdContracor _contracor;
  RequestDeviceId api = new RequestDeviceId();
  DeviceIdPresenter(this._contracor);

  doGetDeviceId() async {
    try {
      DeviceUniqueId data = await api.getDeviceuniqueId();
      if (data == null) {
        _contracor.onDeviceIdError("Update Failed");
      } else {
        _contracor.onDeviceIdSuccess(data.deviceId!);
      }
    } on Exception catch (error) {
      _contracor.onDeviceIdError(error.toString());
    }
  }
}
