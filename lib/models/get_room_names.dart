class RoomName {
  int? status;
  String? message;
  List<Names>? names;

  RoomName({this.status, this.message, this.names});

  RoomName.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['names'] != null) {
      names = <Names>[];
      json['names'].forEach((v) {
        names!.add(new Names.fromJson(v));
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

class Names {
  String? roomName;

  Names({this.roomName});

  Names.fromJson(Map<String, dynamic> json) {
    roomName = json['room_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['room_name'] = this.roomName;
    return data;
  }
}
