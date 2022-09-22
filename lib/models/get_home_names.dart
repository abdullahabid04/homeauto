import 'package:last_home_auto/utils/network_util.dart';

import '../utils/custom_exception.dart';

class HomeName {
  int? status;
  String? message;
  List<HomeNames>? names;

  HomeName({this.status, this.message, this.names});

  HomeName.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['names'] != null) {
      names = <HomeNames>[];
      json['names'].forEach((v) {
        names!.add(new HomeNames.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.names != null) {
      data['names'] = this.names!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HomeNames {
  String? homeName;

  HomeNames({this.homeName});

  HomeNames.fromJson(Map<String, dynamic> json) {
    homeName = json['home_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['home_name'] = this.homeName;
    return data;
  }
}

class RequestNames {
  NetworkUtil _util = new NetworkUtil();
  static const baseURL = "http://care-engg.com/api/names";
  static const namesURL = baseURL + "/home";

  getNames(String user_id) {
    return _util.post(namesURL, body: {"user_id": user_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return HomeName.fromJson(res);
    });
  }
}

abstract class HomeNameContractor {
  void onGetHomeNamesSuccess(List<HomeNames> list);
  void onGetHomeNamesError(String error);
}

class HomeNamePresenter {
  HomeNameContractor _contractor;
  RequestNames api = new RequestNames();
  HomeNamePresenter(this._contractor);

  doGetNames(String user_id) async {
    try {
      HomeName home = await api.getNames(user_id);
      _contractor.onGetHomeNamesSuccess(home.names!);
    } on Exception catch (error) {
      _contractor.onGetHomeNamesError(error.toString());
    }
  }
}
