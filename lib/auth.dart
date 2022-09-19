import '/utils/internet_access.dart';
import '/models/user_data.dart';
import '/userpreferances/user_preferances.dart';

enum AuthState { LOGGED_IN, LOGGED_OUT }

abstract class AuthStateListener {
  void onAuthStateChanged(AuthState state, User? user);
}

class AuthStateProvider implements UserContract {
  bool internetAccess = false;
  UserPresenter? _userPresenter;
  late User user;
  static final AuthStateProvider _instance = new AuthStateProvider.internal();

  List<AuthStateListener>? _subscribers;

  factory AuthStateProvider() => _instance;
  AuthStateProvider.internal() {
    _userPresenter = new UserPresenter(this);
    _subscribers = <AuthStateListener>[];
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    internetAccess = await checkInternetAccess.check();
  }

  void initState() async {
    await getInternetAccessObject();
    String? _user_id = UserSharedPreferences.getUserUniqueId() ?? "";
    bool? _isFirstRun = UserSharedPreferences.getFirstRun() ?? false;
    bool? _isAccountCreated =
        UserSharedPreferences.getAccountCreated() ?? false;
    bool? _isVerified = UserSharedPreferences.getAccountVerified() ?? false;
    bool? _isLoggedIn = UserSharedPreferences.getLoggedIn() ?? false;

    if (_isAccountCreated) {
      print("account created");
      print(_isAccountCreated);
      if (_isVerified) {
        print(_isVerified);
        print("account verified");
        if (_isLoggedIn) {
          print(_isLoggedIn);
          print("lgged in");
          if (internetAccess) {
            print("have internet");
            await _userPresenter!.doGetUser(_user_id);
          } else {
            notify(AuthState.LOGGED_OUT, null);
          }
        } else {
          print("not logged in");
          notify(AuthState.LOGGED_OUT, null);
        }
      } else {
        print("acount not verified");
        notify(AuthState.LOGGED_OUT, null);
      }
    } else {
      print("account not created");
      notify(AuthState.LOGGED_OUT, null);
    }
  }

  void subscribe(AuthStateListener listener) {
    _subscribers!.add(listener);
  }

  void dispose(AuthStateListener listener) {
    for (var l in _subscribers!) {
      if (l == listener) _subscribers!.remove(l);
    }
  }

  void notify(AuthState state, User? user) {
    _subscribers!
        .forEach((AuthStateListener s) => s.onAuthStateChanged(state, user));
  }

  @override
  void onUserError(String? error) {
    notify(AuthState.LOGGED_OUT, null);
  }

  @override
  void onUserSuccess(User userDetails) {
    user = userDetails;
    notify(AuthState.LOGGED_IN, user);
  }
}
