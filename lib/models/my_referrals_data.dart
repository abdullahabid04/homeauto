import '/utils/network_util.dart';
import '/utils/custom_exception.dart';
import '/utils/api_response.dart';

class MyReferrals {
  int? status;
  String? message;
  List<Referrals>? referrals;

  MyReferrals({this.status, this.message, this.referrals});

  MyReferrals.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['referrals'] != null) {
      referrals = <Referrals>[];
      json['referrals'].forEach((v) {
        referrals!.add(new Referrals.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.referrals != null) {
      data['referrals'] = this.referrals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Referrals {
  String? id;
  String? userId;
  String? mobileNo;
  String? referralName;
  String? referralMobile;

  Referrals(
      {this.id,
      this.userId,
      this.mobileNo,
      this.referralName,
      this.referralMobile});

  Referrals.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    mobileNo = json['mobile_no'];
    referralName = json['referral_name'];
    referralMobile = json['referral_mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['mobile_no'] = this.mobileNo;
    data['referral_name'] = this.referralName;
    data['referral_mobile'] = this.referralMobile;
    return data;
  }
}

class ReferralsData {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/referral';
  static final getReferralsURL = baseURL + "/get";
  static final addReferralsURL = baseURL + "/add";

  Future<MyReferrals> getReferrals(String user_id) async {
    return _netUtil
        .post(getReferralsURL, body: {"user_id": user_id}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return MyReferrals.fromJson(res);
    });
  }

  Future<ResponseDataAPI> addReferrals(
      String user_id, String referral_name, String referral_mobile) async {
    return _netUtil.post(getReferralsURL, body: {
      "user_id": user_id,
      "referral_name": referral_name,
      "referral_mobile": referral_mobile
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }
}

abstract class ReferralProgramContractor {
  void onAddReferralSucccss(String? message);
  void onAddReferralError(String? error);
  void onGetReferralSucccss(List<Referrals>? referrals);
  void onGetReferralError(String? error);
}

class ReferralProgramPresetner {
  ReferralProgramContractor _view;
  ReferralsData api = new ReferralsData();
  ReferralProgramPresetner(this._view);

  doGetReferrals(String user_id) async {
    try {
      MyReferrals _myReferrals = await api.getReferrals(user_id);
      if (_myReferrals == null) {
        _view.onGetReferralError("No Referrals Found");
      } else {
        _view.onGetReferralSucccss(_myReferrals.referrals);
      }
    } on Exception catch (error) {
      _view.onGetReferralError(error.toString());
    }
  }

  doGetDevices(
      String user_id, String referral_name, String referral_mobile) async {
    try {
      ResponseDataAPI _response =
          await api.addReferrals(user_id, referral_name, referral_mobile);
      if (_response == null) {
        _view.onAddReferralError(_response.message);
      } else {
        _view.onAddReferralSucccss(_response.message);
      }
    } on Exception catch (error) {
      _view.onAddReferralError(error.toString());
    }
  }
}
