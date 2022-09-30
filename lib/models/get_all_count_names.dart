import '../utils/custom_exception.dart';
import '../utils/network_util.dart';

class GetAllNamesCount {
  int? status;
  String? message;
  int? devicecount;
  int? roomcount;
  int? homecount;

  GetAllNamesCount(
      {this.status,
      this.message,
      this.devicecount,
      this.roomcount,
      this.homecount});

  GetAllNamesCount.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    devicecount = json['devicecount'];
    roomcount = json['roomcount'];
    homecount = json['homecount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['devicecount'] = this.devicecount;
    data['roomcount'] = this.roomcount;
    data['homecount'] = this.homecount;
    return data;
  }
}

class RequestNamesCount {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/names';
  static final controlDeviceURL = baseURL + "/allcount";

  Future<GetAllNamesCount> getAllNamesCount(String user_id) async {
    return _netUtil.post(controlDeviceURL, body: {
      "user_id": user_id,
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return GetAllNamesCount.fromJson(res);
    });
  }
}

abstract class GetNamesCountContract {
  void onGetNamesCountSuccess(int device_count, int room_count, int home_count);
  void onGetNamesCountError();
}

class GetNamesCountPresenter {
  GetNamesCountContract _view;
  RequestNamesCount api = new RequestNamesCount();
  GetNamesCountPresenter(this._view);

  doGetAllNamesCounts(String user_id) async {
    try {
      var counts = await api.getAllNamesCount(user_id);
      if (counts == null) {
        _view.onGetNamesCountError();
      } else {
        _view.onGetNamesCountSuccess(
            counts.devicecount!, counts.roomcount!, counts.homecount!);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onGetNamesCountError();
    }
  }
}
