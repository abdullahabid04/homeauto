import 'package:shared_preferences/shared_preferences.dart';
import '../utils/check_app_first_run.dart';
import '/constants/user_constants.dart';

class UserSharedPreferences {
  static late SharedPreferences _prefsInstance;

  static Future init() async {
    _prefsInstance = await SharedPreferences.getInstance();
    bool status = await CheckAppFirstRun.check();
    print(status);
    setFirstRunStatus(status);
  }

  static Future setLoggedInStatus(bool is_logged_in) async =>
      await _prefsInstance.setBool(UserConstants.IS_LOGGED_IN, is_logged_in);

  static Future setAccountCreatedStatus(bool is_account_created) async =>
      await _prefsInstance.setBool(
          UserConstants.IS_ACCOUNT_CREATED, is_account_created);

  static Future setVerifiedStatus(bool is_verified) async =>
      await _prefsInstance.setBool(UserConstants.IS_VERIFIED, is_verified);

  static Future setFirstRunStatus(bool is_first_run) async =>
      await _prefsInstance.setBool(UserConstants.IS_FIRST_RUN, is_first_run);

  static Future setUserId(int id) async =>
      await _prefsInstance.setInt(UserConstants.ID, id);

  static Future setUserUniqueId(String user_id) async =>
      await _prefsInstance.setString(UserConstants.USER_ID, user_id);

  static Future setUserName(String user_name) async =>
      await _prefsInstance.setString(UserConstants.USER_NAME, user_name);

  static Future setUserEmail(String e_mail) async =>
      await _prefsInstance.setString(UserConstants.E_MAIL, e_mail);

  static Future setUserMobileNo(String mobile_no) async =>
      await _prefsInstance.setString(UserConstants.CONTACT, mobile_no);

  static Future setUserAccountPassword(String password) async =>
      await _prefsInstance.setString(UserConstants.PASSWROD, password);

  static Future setUserCity(String password) async =>
      await _prefsInstance.setString(UserConstants.CITY, password);

  static Future setUserAddress(String address) async =>
      await _prefsInstance.setString(UserConstants.ADDRESS, address);

  static Future setUserCreatedDate(String date_created) async =>
      await _prefsInstance.setString(UserConstants.DATE_CREATED, date_created);

  static Future setUserProfileImagePath(String image_path) async =>
      await _prefsInstance.setString(
          UserConstants.PROFILE_IMAGE_PATH, image_path);

  static Future setUserHomesCount(int home_count) async =>
      await _prefsInstance.setInt(UserConstants.HOME_COUNT, home_count);

  static Future setUserRoomsCount(int room_count) async =>
      await _prefsInstance.setInt(UserConstants.ROOM_COUNT, room_count);

  static Future setUserDevicesCount(int device_count) async =>
      await _prefsInstance.setInt(UserConstants.DEVICE_COUNT, device_count);

  static bool? getLoggedIn() =>
      _prefsInstance.getBool(UserConstants.IS_LOGGED_IN);

  static bool? getAccountCreated() =>
      _prefsInstance.getBool(UserConstants.IS_ACCOUNT_CREATED);

  static bool? getAccountVerified() =>
      _prefsInstance.getBool(UserConstants.IS_VERIFIED);

  static bool? getFirstRun() =>
      _prefsInstance.getBool(UserConstants.IS_FIRST_RUN);

  static int? getUserId() => _prefsInstance.getInt(UserConstants.ID);

  static String? getUserUniqueId() =>
      _prefsInstance.getString(UserConstants.USER_ID);

  static String? getUserName() =>
      _prefsInstance.getString(UserConstants.USER_NAME);

  static String? getUserEmail() =>
      _prefsInstance.getString(UserConstants.E_MAIL);

  static String? getUserMobileNo() =>
      _prefsInstance.getString(UserConstants.CONTACT);

  static String? getUserAccountPassword() =>
      _prefsInstance.getString(UserConstants.PASSWROD);

  static String? getUserCity() => _prefsInstance.getString(UserConstants.CITY);

  static String? getUserAddress() =>
      _prefsInstance.getString(UserConstants.ADDRESS);

  static String? getUserCreatedDate() =>
      _prefsInstance.getString(UserConstants.DATE_CREATED);

  static String? getUserProfileImagePath() =>
      _prefsInstance.getString(UserConstants.PROFILE_IMAGE_PATH);

  static int? getUserHomesCount() =>
      _prefsInstance.getInt(UserConstants.HOME_COUNT);

  static int? getUserRoomsCount() =>
      _prefsInstance.getInt(UserConstants.ROOM_COUNT);

  static int? getUserDevicesCount() =>
      _prefsInstance.getInt(UserConstants.DEVICE_COUNT);
}
