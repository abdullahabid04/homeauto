import 'package:flutter/material.dart';
import 'package:last_home_auto/models/my_shared_devices_data.dart';
import 'package:last_home_auto/models/shared_members_data.dart';
import 'package:last_home_auto/utils/show_status.dart';
import '../../models/user_data.dart';
import '../../userpreferances/user_preferances.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_progress.dart';
import '/models/my_referrals_data.dart';
import 'add_referral.dart';

class MySharedDevices extends StatefulWidget {
  const MySharedDevices({Key? key}) : super(key: key);

  @override
  State<MySharedDevices> createState() => _MySharedDevicesState();
}

class _MySharedDevicesState extends State<MySharedDevices>
    implements SharedDevicesContract {
  bool _isLoading = true;
  late String mobile_no;
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";
  late SharedDevicesPresenter _presenter;
  List<Info> _deviceList = <Info>[];
  late ShowDialog _showDialog;
  var referralFormKey = GlobalKey<FormState>();
  bool _autoValidateComplain = false;
  bool internetAccess = false;
  ScrollController _scrollController = ScrollController();
  ShowStatus _showStatus = new ShowStatus();

  @override
  void initState() {
    _showDialog = new ShowDialog();
    _presenter = new SharedDevicesPresenter(this);
    _getMembers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getMembers() async {
    await _presenter.doGetSharedDevices(user_id);
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Referral Program"),
        centerTitle: true,
        actions: [],
      ),
      body: _isLoading
          ? ShowProgress()
          : _deviceList.length != 0
              ? createListView(context, _deviceList)
              : _showStatus.showStatus("no shared members"),
    );
  }

  Widget _deviceWidget(BuildContext context, Info sharedDevice) {
    return Card(
        child: ListTile(
      title: Text(sharedDevice.deviceName!),
      subtitle: Text(sharedDevice.deviceId!),
      leading: Icon(Icons.person),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: () => {},
      ),
    ));
  }

  Widget createListView(BuildContext context, List<Info> sharedDeviceList) {
    return new ListView.separated(
      itemCount: sharedDeviceList.length,
      itemBuilder: (context, index) =>
          _deviceWidget(context, sharedDeviceList[index]),
      separatorBuilder: (context, index) => new Divider(),
    );
  }

  @override
  void onSharedDeviceError() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSharedDeviceSuccess(SharedDevices deviceInfo) {
    setState(() {
      _deviceList = deviceInfo.info!;
      _isLoading = false;
    });
  }
}
