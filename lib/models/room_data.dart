import '/utils/network_util.dart';
import '/models/home_data.dart';
import '/utils/custom_exception.dart';
import '/utils/api_response.dart';

class RoomData {
  int? status;
  String? message;
  int? total;
  List<Room>? room;

  RoomData({this.status, this.message, this.total, this.room});

  RoomData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['room'] != null) {
      room = <Room>[];
      json['room'].forEach((v) {
        room!.add(new Room.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.room != null) {
      data['room'] = this.room!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Room {
  String? id;
  String? userId;
  String? homeId;
  String? roomId;
  String? roomName;

  Room({this.id, this.userId, this.homeId, this.roomId, this.roomName});

  Room.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    homeId = json['home_id'];
    roomId = json['room_id'];
    roomName = json['room_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['home_id'] = this.homeId;
    data['room_id'] = this.roomId;
    data['room_name'] = this.roomName;
    return data;
  }
}

class SendRoomData {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/room';
  static final createURL = baseURL + "/make";
  static final readURL = baseURL + "/get";
  static final updateURL = baseURL + "/name";
  static final deleteURL = baseURL + "/remove";

  Future<RoomData> getAllRoom(String user_id, String home_id) async {
    return _netUtil.post(readURL,
        body: {"user_id": user_id, "home_id": home_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return RoomData.fromJson(res);
    });
  }

  Future<ResponseDataAPI> create(
      String user_id, String home_id, String room_name) async {
    return _netUtil.post(createURL, body: {
      "user_id": user_id,
      "home_id": home_id,
      "room_name": room_name
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }

  Future<ResponseDataAPI> delete(String user_id, String room_id) async {
    return _netUtil.post(deleteURL,
        body: {"user_id": user_id, "room_id": room_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }

  Future<ResponseDataAPI> rename(
      String user_id, String room_id, String room_name) async {
    return _netUtil.post(updateURL, body: {
      "user_id": user_id,
      "room_id": room_id,
      "room_name": room_name
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }
}

abstract class RoomScreenContract {
  void onSuccess(ResponseDataAPI room);
  void onSuccessDelete(ResponseDataAPI room);
  void onError(String errorTxt);
  void onSuccessRename(ResponseDataAPI room);
}

class RoomScreenPresenter {
  RoomScreenContract _view;
  SendRoomData api = new SendRoomData();
  RoomScreenPresenter(this._view);

  doCreateRoom(String user_id, String home_id, String room_name) async {
    try {
      var room = await api.create(user_id, home_id, room_name);
      _view.onSuccess(room);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doDeleteRoom(String user_id, String room_id) async {
    try {
      var r = await api.delete(user_id, room_id);
      _view.onSuccessDelete(r);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doRenameRoom(String user_id, String room_id, String room_name) async {
    try {
      var r = await api.rename(user_id, room_id, room_name);
      _view.onSuccessRename(r);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }
}

abstract class GetRoomContract {
  void onGetRoomSuccess(RoomData room);
  void onGetRoomError(String errorTxt);
}

class GetRoomPresenter {
  GetRoomContract _view;
  SendRoomData api = new SendRoomData();
  GetRoomPresenter(this._view);

  doGetRoom(String user_id, String home_id) async {
    try {
      var room = await api.getAllRoom(user_id, home_id);
      _view.onGetRoomSuccess(room);
    } on Exception catch (error) {
      _view.onGetRoomError(error.toString());
    }
  }
}
