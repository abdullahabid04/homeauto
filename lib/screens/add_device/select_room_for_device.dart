import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_home_auto/screens/add_device/device_add.dart';
import '../../models/home_data.dart';
import '../../models/manufactured_products.dart';
import '/utils/api_response.dart';
import '/utils/show_dialog.dart';
import '/utils/show_status.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/models/room_data.dart';
import '/models/get_home_names.dart';
import '/screens/userrooms/user_rooms.dart';
import '/userpreferances/user_preferances.dart';

class SelectRoomForDevice extends StatefulWidget {
  final Products product;
  final String device_id;
  final Home home;
  const SelectRoomForDevice(
      {Key? key,
      required this.product,
      required this.device_id,
      required this.home})
      : super(key: key);

  @override
  State<SelectRoomForDevice> createState() => _SelectRoomForDeviceState();
}

class _SelectRoomForDeviceState extends State<SelectRoomForDevice>
    implements GetRoomContract {
  bool _isLoading = true;
  bool internetAccess = false;
  bool _autoValidateHomeReName = false;
  late CheckPlatform _checkPlatform;
  late ShowInternetStatus _showInternetStatus;
  late GetRoomPresenter _presenter;

  late String _roomName;
  List<Room> rooms = <Room>[];
  List<String> homeNames = <String>[];
  String dropDownValue = "";
  String dropDownCreateValue = "";

  var deviceRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  var deviceReNameFormKey = new GlobalKey<FormState>();
  late ShowDialog _showDialog;
  late ShowStatus _showStatus;
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";

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
    _showDialog = new ShowDialog();
    _presenter = new GetRoomPresenter(this);

    checkInternet();

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

  getroomList(String home_name) async {
    await _presenter.doGetRoom(user_id, home_name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("my rooms"),
        actions: [],
      ),
      body: _isLoading
          ? ShowProgress()
          : internetAccess
              ? RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: rooms.length != 0
                      ? _createRoomList(context, rooms)
                      : _showStatus.showStatus("You have currently no rooms"),
                  onRefresh: () => getroomList(dropDownValue),
                )
              : RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: _showInternetStatus
                      .showInternetStatus(_checkPlatform.isIOS()),
                  onRefresh: () => checkInternet()),
    );
  }

  Widget _createRoomWidget(BuildContext context, Room room) {
    return Card(
      child: ListTile(
        title: Text(""),
        subtitle: Text(""),
        leading: Icon(Icons.home),
        trailing: IconButton(
          icon: Icon(Icons.arrow_circle_right),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: ((context) => AddDevice(
                    product: widget.product,
                    device_id: widget.device_id,
                    home: widget.home,
                    room: room,
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createRoomList(BuildContext context, List<Room> homeList) {
    return new ListView.separated(
      itemCount: homeList.length,
      itemBuilder: (context, index) =>
          _createRoomWidget(context, homeList[index]),
      separatorBuilder: (context, index) => new Divider(),
    );
  }

  @override
  void onGetRoomError(String errorTxt) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onGetRoomSuccess(RoomData room) {
    setState(() {
      rooms = room.room!;
    });
    Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }
}
