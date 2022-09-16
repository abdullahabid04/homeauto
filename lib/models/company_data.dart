import '/utils/network_util.dart';
import '/utils/custom_exception.dart';
import '/utils/api_response.dart';

class CompanyData {
  int? status;
  String? message;
  List<Contactor>? contactor;

  CompanyData({this.status, this.message, this.contactor});

  CompanyData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['contactor'] != null) {
      contactor = <Contactor>[];
      json['contactor'].forEach((v) {
        contactor!.add(new Contactor.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.contactor != null) {
      data['contactor'] = this.contactor!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Contactor {
  String? id;
  String? contactorName;
  String? contactorMobile;
  String? contactorEmail;
  String? contactorRole;

  Contactor(
      {this.id,
      this.contactorName,
      this.contactorMobile,
      this.contactorEmail,
      this.contactorRole});

  Contactor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    contactorName = json['contactor_name'];
    contactorMobile = json['contactor_mobile'];
    contactorEmail = json['contactor_email'];
    contactorRole = json['contactor_role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['contactor_name'] = this.contactorName;
    data['contactor_mobile'] = this.contactorMobile;
    data['contactor_email'] = this.contactorEmail;
    data['contactor_role'] = this.contactorRole;
    return data;
  }
}

class RequestCompany {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/company';
  static final getContactsURL = baseURL + "/contacts";
  static final sendComplaintURL = baseURL + "/complaint";

  Future<CompanyData> getContacts() async {
    return _netUtil.get(getContactsURL).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return CompanyData.fromJson(res);
    });
  }

  Future<ResponseDataAPI> sendComplaint(
      String user_id, String complaint) async {
    return _netUtil.post(sendComplaintURL,
        body: {"user_id": user_id, "complain": complaint}).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }
}

abstract class CompanyDataContract {
  void onCompanyGetContactsSuccess(List<Contactor>? contactors);
  void onCompanyGetContactsError(String error);
  void onCompanySendComplaintSuccess(String message);
  void onCompanySendComplaintError(String error);
}

class CompanyDataPresenter {
  CompanyDataContract _view;
  RequestCompany api = new RequestCompany();
  CompanyDataPresenter(this._view);

  doGetContacts() async {
    try {
      CompanyData data = await api.getContacts();
      if (data == null) {
        _view.onCompanyGetContactsError("Update Failed");
      } else {
        _view.onCompanyGetContactsSuccess(data.contactor);
      }
    } on Exception catch (error) {
      _view.onCompanyGetContactsError(error.toString());
    }
  }

  doSendComplaint(String? user_id, String? complaint) async {
    try {
      ResponseDataAPI data = await api.sendComplaint(user_id!, complaint!);
      if (data == null) {
        _view.onCompanySendComplaintError("Update Failed");
      } else {
        _view.onCompanySendComplaintSuccess(data.message!);
      }
    } on Exception catch (error) {
      _view.onCompanySendComplaintError(error.toString());
    }
  }
}
