import '../utils/custom_exception.dart';
import '../utils/network_util.dart';

class SharedMembersData {
  int? status;
  String? message;
  List<Members>? members;

  SharedMembersData({this.status, this.message, this.members});

  SharedMembersData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Members {
  String? id;
  String? userId;
  String? userName;
  String? userContact;

  Members({this.id, this.userId, this.userName, this.userContact});

  Members.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    userContact = json['user_contact'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['user_contact'] = this.userContact;
    return data;
  }
}

class RequestSharedMembers {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/members';
  static final getShredMembersURL = baseURL + "/shared";

  Future<SharedMembersData> getMembers(String user) async {
    return _netUtil
        .post(getShredMembersURL, body: {"user_id": user}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return SharedMembersData.fromJson(res);
    });
  }
}

abstract class MembersContract {
  void onGetMembersSuccess(SharedMembersData userDetails);
  void onGetMembersErrors();
}

class MembersPresenter {
  MembersContract _view;
  RequestSharedMembers api = new RequestSharedMembers();
  MembersPresenter(this._view);

  doGetMembers(String user_id) async {
    try {
      var devices = await api.getMembers(user_id);
      if (devices == null) {
        _view.onGetMembersErrors();
      } else {
        _view.onGetMembersSuccess(devices);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onGetMembersErrors();
    }
  }
}
