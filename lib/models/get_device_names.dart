class DeviceName {
  int? status;
  String? message;
  List<Names>? names;

  DeviceName({this.status, this.message, this.names});

  DeviceName.fromJson(Map<String, dynamic> json) {
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
  String? deviceName;

  Names({this.deviceName});

  Names.fromJson(Map<String, dynamic> json) {
    deviceName = json['device_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device_name'] = this.deviceName;
    return data;
  }
}
