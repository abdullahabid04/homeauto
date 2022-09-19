import '/utils/network_util.dart';
import '/utils/custom_exception.dart';
import '/utils/api_response.dart';

class RequestVerify {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://care-engg.com/api/user';
  static final verifyURL = baseURL + "/verify";

  Future<ResponseDataAPI> verifyAccount(
      String user_id, String verification_code) async {
    return _netUtil.post(verifyURL, body: {
      "user_id": user_id,
      "verification_code": verification_code
    }).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ResponseDataAPI.fromJson(res);
    });
  }
}

abstract class VerifyAccountContractor {
  void onVerifyAccountSuccess(String? message);
  void onVerifyAccountError(String? error);
}

class AccountVerifyPresenter {
  VerifyAccountContractor _contractor;
  RequestVerify api = new RequestVerify();
  AccountVerifyPresenter(this._contractor);

  doVerify(String user_id, String code) async {
    try {
      var res = await api.verifyAccount(user_id, code);
      if (res == null) {
        _contractor.onVerifyAccountError(res.message);
      } else {
        _contractor.onVerifyAccountSuccess(res.message);
      }
    } on Exception catch (e) {
      _contractor.onVerifyAccountError(e.toString());
    }
  }
}
