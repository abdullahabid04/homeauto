import '/utils/internet_access.dart';
import '/models/user_data.dart';

enum AuthState { LOGGED_IN, LOGGED_OUT }

abstract class AuthStateListener {
  void onAuthStateChanged(AuthState state, User user);
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
    bool isLoggedIn = true;
    var user_id = "Boygood-0000000000";
    if (isLoggedIn) {
      if (internetAccess) {
        await _userPresenter!.doGetUser(user_id);
        print("hello if");
      } else {
        await _userPresenter!.doGetUser(user_id);
        print("hello else");
      }
    } else {
      User user = new User(0, "", "", "", "", "", "", "", "");
      notify(AuthState.LOGGED_OUT, user);
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

  void notify(AuthState state, User user) {
    _subscribers!
        .forEach((AuthStateListener s) => s.onAuthStateChanged(state, user));
  }

  @override
  void onUserError() {
    User user = new User(0, "", "", "", "", "", "", "", "");
    notify(AuthState.LOGGED_OUT, user);
  }

  @override
  void onUserSuccess(User userDetails) {
    user = userDetails;
    notify(AuthState.LOGGED_IN, user);
  }
}
