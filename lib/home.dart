import 'package:flutter/material.dart';
import 'package:last_home_auto/userpreferances/user_preferances.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/models/user_data.dart';
import '/profile/get_to_user_profile.dart';
import 'screens/device/device_screen.dart';
import 'package:flutter/services.dart';
import '/UserDashBoard/mydrawer.dart';
import 'models/device_data.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  HomeScreen({this.user, this.callbackUser});
  @override
  HomeScreenState createState() {
    return new HomeScreenState(user!, callbackUser!);
  }
}

class HomeScreenState extends State<HomeScreen> implements DeviceContract {
  bool _isLoading = true;
  bool internetAccess = false;
  late CheckPlatform _checkPlatform;
  late ShowInternetStatus _showInternetStatus;
  late GoToUserProfile _goToUserProfile;
  late DevicePresenter _presenter;
  List<Devices> devices = <Devices>[];
  late MyDrawer _myDrawer;
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var homeRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  late User user;
  late Function callbackUser;

  callbackThis(User user) {
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
    await _presenter.doGetDevices(user_id);
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState!.removeCurrentSnackBar();
    scaffoldKey.currentState!
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    _myDrawer = new MyDrawer(
      user: this.user,
      callbackUser: this.callbackUser,
    );

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
          actions: <Widget>[],
        ),
        body: _isLoading
            ? ShowProgress()
            : internetAccess
                ? RefreshIndicator(
                    key: homeRefreshIndicatorKey,
                    child: devices.length != 0
                        ? UserDevices(
                            deviceList: devices,
                          )
                        : Container(),
                    onRefresh: () => getDeviceList(),
                  )
                : RefreshIndicator(
                    key: homeRefreshIndicatorKey,
                    child: _showInternetStatus
                        .showInternetStatus(_checkPlatform.isIOS()),
                    onRefresh: () => checkInternet()),
      ),
    );
  }

  @override
  void onDeviceError() {}

  @override
  void onDeviceSuccess(DeviceData userDetails) {
    setState(() {
      devices = userDetails.devices!;
    });
    Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }
}
