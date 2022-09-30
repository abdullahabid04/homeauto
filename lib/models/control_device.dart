import '/utils/api_response.dart';
import '../utils/custom_exception.dart';
import '../utils/network_util.dart';

class RequestControlDevice {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/device';
  static final controlDeviceURL = baseURL + "/control";

  Future<ResponseDataAPI> controlDevice(
      String device_id, String port_id, String port_status) async {
    return _netUtil.post(controlDeviceURL, body: {
      "device_id": device_id,
      "port_id": port_id,
      "port_status": port_status,
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }
}

abstract class DeviceControlContract {
  void onControlDeviceSuccess(String? message);
  void onControlDeviceError();
}

class DeviceControlPresenter {
  DeviceControlContract _view;
  RequestControlDevice api = new RequestControlDevice();
  DeviceControlPresenter(this._view);

  doControlDevice(String device_id, String port_id, String port_status) async {
    try {
      var devicePower =
          await api.controlDevice(device_id, port_id, port_status);
      if (devicePower == null) {
        _view.onControlDeviceError();
      } else {
        _view.onControlDeviceSuccess(devicePower.message);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onControlDeviceError();
    }
  }
}
