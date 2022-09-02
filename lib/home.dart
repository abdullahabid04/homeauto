import 'package:flutter/material.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/models/user_data.dart';
import '/get_to_user_profile.dart';
import '/UserDashBoard/user_dashboard.dart';
import 'package:flutter/services.dart';
import '/UserDashBoard/mydrawer.dart';
import '/screens/device/device_data.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final Function callbackUser;
  HomeScreen({this.user, this.callbackUser});
  @override
  HomeScreenState createState() {
    return new HomeScreenState(user, callbackUser);
  }
}

class HomeScreenState extends State<HomeScreen> implements DeviceContract {
  bool _isLoading = true;
  bool internetAccess = false;
  CheckPlatform _checkPlatform;
  ShowInternetStatus _showInternetStatus;
  GoToUserProfile _goToUserProfile;
  DevicePresenter _presenter;
  List<Devices> devices = new List<Devices>();
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
    _presenter = new DevicePresenter(this);
    checkInternet();
    getDeviceList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  getDeviceList() async {
    DeviceData _deviceData =
        await _presenter.doGetDevices("12-abdullahnew-2244668800");
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
                    child: DashBoard(
                      deviceList: devices,
                    ),
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

  @override
  void onDeviceError() {
    // TODO: implement onDeviceError
  }

  @override
  void onDeviceSuccess(DeviceData userDetails) {
    setState(() {
      devices = userDetails.devices;
    });
    setState(() {
      _isLoading = false;
    });
  }
}
