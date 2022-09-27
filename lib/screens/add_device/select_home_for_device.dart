import 'package:flutter/material.dart';
import 'package:last_home_auto/screens/add_device/select_room_for_device.dart';
import 'package:last_home_auto/utils/api_response.dart';
import '../../models/manufactured_products.dart';
import '../../userpreferances/user_preferances.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_status.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/screens/userhomes/user_home.dart';
import 'package:flutter/services.dart';
import '/models/home_data.dart';

class SelectHomeForDevice extends StatefulWidget {
  final Products product;
  final String device_id;
  const SelectHomeForDevice(
      {Key? key, required this.product, required this.device_id})
      : super(key: key);

  @override
  State<SelectHomeForDevice> createState() => _SelectHomeForDeviceState();
}

class _SelectHomeForDeviceState extends State<SelectHomeForDevice>
    implements GetHomeContract {
  bool _isLoading = true;
  bool internetAccess = false;
  bool _autoValidateHomeReName = true;
  late CheckPlatform _checkPlatform;
  late ShowInternetStatus _showInternetStatus;
  late GetHomePresenter _presenter;
  List<Home> homes = <Home>[];
  late ShowStatus _showStatus;
  late String _homeName;
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final homeRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  var deviceReNameFormKey = new GlobalKey<FormState>();
  late ShowDialog _showDialog;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _checkPlatform = new CheckPlatform(context: context);
    _showInternetStatus = new ShowInternetStatus();
    _showStatus = new ShowStatus();
    _showDialog = new ShowDialog();
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
    await _presenter.doGetHome(user_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Homse"),
        actions: [],
      ),
      body: _isLoading
          ? ShowProgress()
          : internetAccess
              ? RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: homes.length != 0
                      ? _createHomeList(context, homes)
                      : _showStatus.showStatus("You have currently no rooms"),
                  onRefresh: () => gethomeList(),
                )
              : RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: _showInternetStatus
                      .showInternetStatus(_checkPlatform.isIOS()),
                  onRefresh: () => checkInternet()),
    );
  }

  Widget _createHomeWidget(BuildContext context, Home home) {
    return Card(
      child: ListTile(
        title: Text(home.homeId!),
        subtitle: Text(home.homeName!),
        leading: Icon(Icons.home),
        trailing: IconButton(
          icon: Icon(Icons.arrow_circle_right),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => SelectRoomForDevice(
                    product: widget.product,
                    device_id: widget.device_id,
                    home: home,
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createHomeList(BuildContext context, List<Home> homeList) {
    return new ListView.separated(
      itemCount: homeList.length,
      itemBuilder: (context, index) =>
          _createHomeWidget(context, homeList[index]),
      separatorBuilder: (context, index) => new Divider(),
    );
  }

  @override
  void onGetHomeError(String errorText) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onGetHomeSuccess(HomeData home) {
    setState(() {
      homes = home.home!;
    });
    Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }
}
