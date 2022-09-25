import 'package:flutter/material.dart';
import 'package:last_home_auto/screens/add_device/device_list.dart';
import '../../userpreferances/user_preferances.dart';
import '../../utils/show_status.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/screens/device/device_screen.dart';
import 'package:flutter/services.dart';
import '/models/device_data.dart';
import '/screens/add_device/connect_to_device.dart';

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
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";
  late ShowStatus _showStatus;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final homeRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _checkPlatform = new CheckPlatform(context: context);
    _showInternetStatus = new ShowInternetStatus();
    _showStatus = new ShowStatus();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Devices"),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => ManufacturedDevices()))),
              icon: Icon(Icons.add))
        ],
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
                      : _showStatus.showStatus("You have currently no devices"),
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
    setState(() {
      _isLoading = false;
    });
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
