import 'package:flutter/material.dart';
import '/models/home_data.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/models/user_data.dart';
import '/get_to_user_profile.dart';
import '/UserDashBoard/user_dashboard.dart';
import 'package:flutter/services.dart';
import '/UserDashBoard/mydrawer.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final Function callbackUser;
  HomeScreen({this.user, this.callbackUser});
  @override
  HomeScreenState createState() {
    return new HomeScreenState(user, callbackUser);
  }
}

class HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool internetAccess = false;
  CheckPlatform _checkPlatform;
  ShowInternetStatus _showInternetStatus;
  GoToUserProfile _goToUserProfile;
  MyDrawer _myDrawer;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var homeRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  User user;
  Function callbackUser;

  Function callbackThis(User user) {
    this.callbackUser(user);
    setState(() {
      this.user = user;
    });
  }

  HomeScreenPresenter _presenter;
  HomeScreenState(User user, Function callbackUser) {
    this.user = user;
    this.callbackUser = callbackUser;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _checkPlatform = new CheckPlatform(context: context);
    _showInternetStatus = new ShowInternetStatus();
    checkInternet();
    super.initState();
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
  }

  checkInternet() async {
    await getInternetAccessObject();
  }

  @override
  Widget build(BuildContext context) {
    _goToUserProfile = new GoToUserProfile(
        context: context,
        isIOS: _checkPlatform.isIOS(),
        user: user,
        callbackThis: this.callbackThis);
    _myDrawer = new MyDrawer();

    return WillPopScope(
      onWillPop: () => new Future<bool>.value(false),
      child: new Scaffold(
        key: scaffoldKey,
        drawer: _myDrawer,
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(
            "Home Automation",
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
          actions: <Widget>[
            _goToUserProfile.showUser(),
          ],
        ),
        body: _isLoading
            ? ShowProgress()
            : internetAccess
                ? RefreshIndicator(
                    key: homeRefreshIndicatorKey,
                    child: DashBoard(),
                    onRefresh: () {},
                  )
                : RefreshIndicator(
                    key: homeRefreshIndicatorKey,
                    child: _showInternetStatus
                        .showInternetStatus(_checkPlatform.isIOS()),
                    onRefresh: () {},
                  ),
      ),
    );
  }
}
