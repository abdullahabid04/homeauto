import '/utils/network_util.dart';
import '/utils/custom_exception.dart';
import '/utils/api_response.dart';

class HomeData {
  int? status;
  String? message;
  int? total;
  List<Home>? home;

  HomeData({this.status, this.message, this.total, this.home});

  HomeData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['home'] != null) {
      home = <Home>[];
      json['home'].forEach((v) {
        home!.add(new Home.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.home != null) {
      data['home'] = this.home!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Home {
  String? id;
  String? userId;
  String? homeId;
  String? homeName;

  Home({this.id, this.userId, this.homeId, this.homeName});

  Home.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    homeId = json['home_id'];
    homeName = json['home_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['home_id'] = this.homeId;
    data['home_name'] = this.homeName;
    return data;
  }
}

class SendHomeData {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/home';
  static final createURL = baseURL + "/make";
  static final readURL = baseURL + "/get";
  static final updateURL = baseURL + "/name";
  static final deleteURL = baseURL + "/remove";

  Future<HomeData> getAllHome(String user_id) async {
    return _netUtil
        .post(readURL, body: {"user_id": user_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return HomeData.fromJson(res);
    });
  }

  Future<ResponseDataAPI> create(String user_id, String home_name) async {
    return _netUtil.post(createURL,
        body: {"user_id": user_id, "home_name": home_name}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }

  Future<ResponseDataAPI> delete(String user_id, String home_id) async {
    return _netUtil.post(deleteURL,
        body: {"user_id": user_id, "home_id": home_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }

  Future<ResponseDataAPI> rename(
      String user_id, String home_id, String home_name) async {
    return _netUtil.post(updateURL, body: {
      "uer_id": user_id,
      "home_id": user_id,
      "home_name": home_name
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }
}

abstract class HomeScreenContract {
  void onSuccess(ResponseDataAPI home);
  void onSuccessDelete(ResponseDataAPI home);
  void onSuccessRename(ResponseDataAPI home);
  void onError(String errorTxt);
}

class HomeScreenPresenter {
  HomeScreenContract _view;
  SendHomeData api = new SendHomeData();
  HomeScreenPresenter(this._view);

  doCreateHome(String user_id, String home_name) async {
    try {
      var home = await api.create(user_id, home_name);
      _view.onSuccess(home);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doDeleteHome(String user_id, String home_id) async {
    try {
      var h = await api.delete(user_id, home_id);
      _view.onSuccessDelete(h);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doRenameHome(String user_id, String home_id, String home_name) async {
    try {
      var h = await api.rename(user_id, home_id, home_name);
      _view.onSuccessRename(h);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }
}

abstract class GetHomeContract {
  void onGetHomeSuccess(HomeData home);
  void onGetHomeError(String errorText);
}

class GetHomePresenter {
  GetHomeContract _view;
  SendHomeData api = new SendHomeData();
  GetHomePresenter(this._view);

  doGetHome(String user_id) async {
    try {
      var home = await api.getAllHome(user_id);
      _view.onGetHomeSuccess(home);
    } on Exception catch (error) {
      _view.onGetHomeError(error.toString());
    }
  }
}
