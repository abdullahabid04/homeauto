import '/utils/network_util.dart';
import '/models/home_data.dart';
import '/utils/custom_exception.dart';

class Room {
  String _roomName, _userID, _homeID, _roomID;
  int _id;
  Room(this._roomName, this._userID, this._homeID, this._id, this._roomID);
  Room.map(dynamic obj) {
    var id = obj['id'].toString();
    this._id = int.parse(id);
    this._userID = obj["user_id"];
    this._homeID = obj['home_id'];
    this._roomID = obj['room_id'];
    this._roomName = obj["room_name"];
  }

  int get id => _id;
  String get roomName => _roomName;
  String get userID => _userID;
  String get homeID => _homeID;
  String get roomID => _roomID;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = _id;
    map["user_id"] = _userID;
    map['home_id'] = _homeID;
    map['room_id'] = _roomID;
    map["room_name"] = _roomName;
    return map;
  }

  @override
  String toString() {
    return roomName;
  }
}

class SendRoomData {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/room';
  static final createURL = baseURL + "/make";
  static final readURL = baseURL + "/get";
  static final updateURL = baseURL + "/name";
  static final deleteURL = baseURL + "/remove";

  Future<List<Room>> getAllRoom(Home home) async {
    final user = home.userID;
    final homeID = home.homeID;
    return _netUtil.post(readURL,
        body: {"user_id": user, "home_id": homeID}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      int total = int.parse(res['total'].toString());
      List<Room> roomList = new List<Room>();
      for (int i = 0; i < total; i++) {
        roomList.add(Room.map(res['room'][i]));
      }
      return roomList;
    });
  }

  Future<Room> create(String roomName, Home home) async {
    final homeID = home.homeID;
    final user = home.userID;
    return _netUtil.post(createURL, body: {
      "user_id": user,
      "home_id": homeID,
      "room_name": roomName
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return new Room.map(res['room']);
    });
  }

  Future<Room> delete(Room room) async {
    final user = room.userID;
    final id = room.roomID;
    return _netUtil
        .post(deleteURL, body: {"user_id": user, "id": id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return room;
    });
  }

  Future<Room> rename(Room room, String roomName) async {
    final user = room.userID;
    final id = room.roomID;
    return _netUtil.post(updateURL, body: {
      "user_id": user,
      "room_id": id,
      "room_name": roomName
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      room._roomName = roomName;
      return room;
    });
  }
}

abstract class RoomScreenContract {
  void onSuccess(Room room);
  void onSuccessDelete(Room room);
  void onError(String errorTxt);
  void onSuccessRename(Room room);
}

class RoomScreenPresenter {
  RoomScreenContract _view;
  SendRoomData api = new SendRoomData();
  RoomScreenPresenter(this._view);

  doCreateRoom(String roomName, Home home) async {
    try {
      var room = await api.create(roomName, home);
      _view.onSuccess(room);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doDeleteRoom(Room room) async {
    try {
      var r = await api.delete(room);
      _view.onSuccessDelete(r);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doRenameRoom(Room room, String roomName) async {
    try {
      var r = await api.rename(room, roomName);
      _view.onSuccessRename(r);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }
}
