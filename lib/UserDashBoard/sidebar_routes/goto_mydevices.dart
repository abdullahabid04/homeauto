import 'package:flutter/material.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/screens/device/device_screen.dart';
import 'package:flutter/services.dart';
import '/models/device_data.dart';

class MyDevices extends StatefulWidget {
  const MyDevices({Key? key}) : super(key: key);

  @override
  State<MyDevices> createState() => _MyDevicesState();
}

class _MyDevicesState extends State<MyDevices> implements DeviceContract {
  bool _isLoading = true;
  bool internetAccess = false;
  late CheckPlatform _checkPlatform;
  late ShowInternetStatus _showInternetStatus;
  late DevicePresenter _presenter;
  List<Devices> devices = <Devices>[];

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final homeRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

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
    await _presenter.doGetDevices("13-abdullah-1029384756");
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
                  child: UserDevices(
                    deviceList: devices,
                  ),
                  onRefresh: () => getDeviceList(),
                )
              : RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: _showInternetStatus
                      .showInternetStatus(_checkPlatform.isIOS()),
                  onRefresh: () => checkInternet()),
    );
  }

  @override
  void onDeviceError() {
    // TODO: implement onDeviceError
  }

  @override
  void onDeviceSuccess(DeviceData userDetails) {
    setState(() {
      devices = userDetails.devices!;
    });
    Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }
}
