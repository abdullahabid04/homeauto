import 'package:flutter/material.dart';
import 'package:last_home_auto/screens/userrooms/user_rooms.dart';
import 'package:last_home_auto/utils/api_response.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/utils/check_platform.dart';
import '/utils/show_internet_status.dart';
import '/screens/userhomes/user_home.dart';
import 'package:flutter/services.dart';
import '/models/room_data.dart';

class MyRooms extends StatefulWidget {
  const MyRooms({Key key}) : super(key: key);

  @override
  State<MyRooms> createState() => _MyRoomsState();
}

class _MyRoomsState extends State<MyRooms> implements GetRoomContract {
  bool _isLoading = true;
  bool internetAccess = false;
  CheckPlatform _checkPlatform;
  ShowInternetStatus _showInternetStatus;
  GetRoomPresenter _presenter;
  List<Room> rooms = new List<Room>();

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final homeRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _checkPlatform = new CheckPlatform(context: context);
    _showInternetStatus = new ShowInternetStatus();
    _presenter = new GetRoomPresenter(this);
    checkInternet();
    getroomList();
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

  getroomList() async {
    await _presenter.doGetRoom("12-abdullahnew-2244668800", "home1-1106");
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
                  child: UserRooms(
                    roomList: rooms,
                  ),
                  onRefresh: () => getroomList(),
                )
              : RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: _showInternetStatus
                      .showInternetStatus(_checkPlatform.isIOS()),
                  onRefresh: () => checkInternet()),
    );
  }

  @override
  void onGetRoomError(String errorTxt) {
    // TODO: implement onGetRoomError
  }

  @override
  void onGetRoomSuccess(RoomData room) {
    setState(() {
      rooms = room.room;
    });
    Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }
}
