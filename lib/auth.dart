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
    getInternetAccessObject();
  }
  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    internetAccess = await checkInternetAccess.check();
  }

  void initState() async {
    String? user_id = UserSharedPreferences.getUserUniqueId() ?? "";
    bool? _isFirstRun = UserSharedPreferences.getFirstRun() ?? false;
    bool? _isAccountCreated = UserSharedPreferences.getFirstRun() ?? false;
    bool? _isVerified = UserSharedPreferences.getFirstRun() ?? false;
    bool? _isLoggedIn = UserSharedPreferences.getFirstRun() ?? false;

    if (_isFirstRun) {
      notify(AuthState.LOGGED_IN, user);
    } else {
      if (_isAccountCreated) {
        if (_isVerified) {
          if (_isLoggedIn) {
            if (internetAccess) {
              await _userPresenter!.doGetUser(user_id);
            } else {
              await _userPresenter!.doGetUser(user_id);
            }
          } else {
            notify(AuthState.LOGGED_OUT, null);
          }
        } else {
          notify(AuthState.LOGGED_OUT, null);
        }
      } else {
        notify(AuthState.LOGGED_OUT, null);
      }
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
