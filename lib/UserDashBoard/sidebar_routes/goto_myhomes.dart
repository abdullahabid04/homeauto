import 'package:flutter/material.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/screens/userhomes/user_home.dart';
import 'package:flutter/services.dart';
import '/models/home_data.dart';

class MyHomes extends StatefulWidget {
  const MyHomes({Key key}) : super(key: key);

  @override
  State<MyHomes> createState() => _MyHomesState();
}

class _MyHomesState extends State<MyHomes> implements GetHomeContract {
  bool _isLoading = true;
  bool internetAccess = false;
  CheckPlatform _checkPlatform;
  ShowInternetStatus _showInternetStatus;
  GetHomePresenter _presenter;
  List<Home> homes = new List<Home>();

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final homeRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _checkPlatform = new CheckPlatform(context: context);
    _showInternetStatus = new ShowInternetStatus();
    _presenter = new GetHomePresenter(this);
    checkInternet();
    gethomeList();
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

  gethomeList() async {
    await _presenter.doGetHome("12-abdullahnew-2244668800");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? ShowProgress()
          : internetAccess
              ? RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: UserHomes(
                    homeList: homes,
                  ),
                  onRefresh: () => gethomeList(),
                )
              : RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: _showInternetStatus
                      .showInternetStatus(_checkPlatform.isIOS()),
                  onRefresh: () => checkInternet()),
    );
  }

  @override
  void onGetHomeError(String errorText) {
    // TODO: implement onGetHomeError
  }

  @override
  void onGetHomeSuccess(HomeData home) {
    setState(() {
      homes = home.home;
    });
    Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }
}
