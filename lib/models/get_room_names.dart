import '../utils/custom_exception.dart';
import '../utils/network_util.dart';

class RoomName {
  int? status;
  String? message;
  List<RoomNames>? names;

  RoomName({this.status, this.message, this.names});

  RoomName.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['names'] != null) {
      names = <RoomNames>[];
      json['names'].forEach((v) {
        names!.add(new RoomNames.fromJson(v));
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

class RoomNames {
  String? roomName;

  RoomNames({this.roomName});

  RoomNames.fromJson(Map<String, dynamic> json) {
    roomName = json['room_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['room_name'] = this.roomName;
    return data;
  }
}

class RequestNames {
  NetworkUtil _util = new NetworkUtil();
  static const baseURL = "http://care-engg.com/api/names";
  static const namesURL = baseURL + "/room";

  getNames(String user_id) {
    return _util.post(namesURL, body: {"user_id": user_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return RoomName.fromJson(res);
    });
  }
}

abstract class RoomNameContractor {
  void onGetRoomNamesSuccess(List<RoomNames> list);
  void onGetRoomNamesError(String error);
}

class RoomNamePresenter {
  RoomNameContractor _contractor;
  RequestNames api = new RequestNames();
  RoomNamePresenter(this._contractor);

  doGetNames(String user_id) async {
    try {
      RoomName room = await api.getNames(user_id);
      _contractor.onGetRoomNamesSuccess(room.names!);
    } on Exception catch (error) {
      _contractor.onGetRoomNamesError(error.toString());
    }
  }
}
