import '/utils/network_util.dart';
import '/utils/custom_exception.dart';

class Home {
  String _homeName, _userID, _homeID;
  int _id;
  Home(this._homeName, this._userID, this._id, this._homeID);
  Home.map(dynamic obj) {
    var id = obj['id'].toString();
    this._id = int.parse(id);
    this._userID = obj["email"];
    this._homeID = obj["home_id"];
    this._homeName = obj["home_name"];
  }
  int get id => _id;
  String get userID => _userID;
  String get homeID => _homeID;
  String get homeName => _homeName;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = _id;
    map["user_id"] = _userID;
    map["home_id"] = _homeID;
    map["home_name"] = _homeName;
    return map;
  }

  @override
  String toString() {
    return homeName;
  }
}

class SendHomeData {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/home';
  static final createURL = baseURL + "/make";
  static final readURL = baseURL + "/get";
  static final updateURL = baseURL + "/name";
  static final deleteURL = baseURL + "/remove";

  Future<List<Home>> getAllHome() async {
    return _netUtil
        .post(readURL, body: {"user_id": "user"}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      int total = int.parse(res['total'].toString());
      List<Home> homeList = new List<Home>();
      for (int i = 0; i < total; i++) {
        homeList.add(Home.map(res['home'][i]));
      }
      return homeList;
    });
  }

  Future<Home> create(String homeName) async {
    // final user = await db.getUser();
    return _netUtil.post(createURL,
        body: {"user_id": "user", "home_name": homeName}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return new Home.map(res['home']);
    });
  }

  Future<Home> delete(Home home) async {
    final user = home.userID;
    final id = home.homeID;
    return _netUtil.post(deleteURL,
        body: {"user_id": user, "home_id": id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return home;
    });
  }

  Future<Home> rename(Home home, String homeName) async {
    final user = home.userID;
    final id = home.homeID;
    return _netUtil.post(updateURL, body: {
      "uer_id": user,
      "home_id": id,
      "home_name": homeName
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      home._homeName = homeName;
      return home;
    });
  }
}

abstract class HomeScreenContract {
  void onSuccess(Home home);
  void onSuccessDelete(Home home);
  void onError(String errorTxt);
  void onSuccessRename(Home home);
}

class HomeScreenPresenter {
  HomeScreenContract _view;
  SendHomeData api = new SendHomeData();
  HomeScreenPresenter(this._view);

  doCreateHome(String homeName) async {
    try {
      var home = await api.create(homeName);
      _view.onSuccess(home);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doDeleteHome(Home home) async {
    try {
      var h = await api.delete(home);
      _view.onSuccessDelete(h);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doRenameHome(Home home, String homeName) async {
    try {
      var h = await api.rename(home, homeName);
      _view.onSuccessRename(h);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }
}
