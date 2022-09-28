import 'package:flutter/material.dart';
import 'package:last_home_auto/models/room_data.dart';
import 'package:last_home_auto/screens/device/my_devices.dart';
import 'package:last_home_auto/utils/api_response.dart';
import 'package:last_home_auto/utils/show_progress.dart';
import '../../constants/colors.dart';
import '../../models/home_data.dart';
import '../../constants/colors.dart';
import 'package:flutter/services.dart';
import '../../userpreferances/user_preferances.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_internet_status.dart';
import '/utils/delete_confirmation.dart';
import '/validators/all_validators.dart';

class UserRoomsFromHome extends StatefulWidget {
  final Home home;
  const UserRoomsFromHome({Key? key, required this.home}) : super(key: key);

  @override
  State<UserRoomsFromHome> createState() => _UserRoomsFromHomeState();
}

class _UserRoomsFromHomeState extends State<UserRoomsFromHome>
    implements RoomScreenContract, GetRoomContract {
  bool _isLoading = true;
  bool internetAccess = false;
  late ShowDialog _showDialog;
  late ShowInternetStatus _showInternetStatus;
  List<Room> roomList = <Room>[];

  late String _roomName;
  var roomNameFormKey = new GlobalKey<FormState>();
  var roomReNameFormKey = new GlobalKey<FormState>();
  bool _autoValidateHomeName = false;
  bool _autoValidateHomeReName = false;

  late RoomScreenPresenter _presenter;
  late GetRoomPresenter _roomPresenter;
  late DeleteConfirmation _confirmation;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var roomRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _confirmation = new DeleteConfirmation();
    _presenter = new RoomScreenPresenter(this);
    _roomPresenter = new GetRoomPresenter(this);
    _showDialog = new ShowDialog();
    _showInternetStatus = new ShowInternetStatus();
    _getrooms();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getrooms() async {
    await _roomPresenter.doGetRoom(user_id, widget.home.homeName!);
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
  }

  _renameRoom(String? user_id, String? room_id, String room_name) async {
    await _presenter.doRenameRoom(user_id!, room_id!, room_name);
  }

  _showRoomReNameDialog(Room room) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: roomReNameFormKey,
                child: new TextFormField(
                  initialValue: room.roomName,
                  onSaved: (val) => _roomName = val!,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) async {
                    await getInternetAccessObject();
                    if (internetAccess) {
                      var form = roomReNameFormKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        Navigator.pop(context);
                        setState(() {
                          _isLoading = true;
                          _autoValidateHomeReName = false;
                        });
                        _renameRoom(room.userId, room.roomId, _roomName);
                      } else {
                        setState(() {
                          _autoValidateHomeReName = true;
                        });
                      }
                    } else {
                      Navigator.pop(context);
                      this._showDialog.showDialogCustom(
                          context,
                          "Internet Connection Problem",
                          "Please check your internet connection",
                          fontSize: 17.0,
                          boxHeight: 58.0);
                    }
                  },
                  autofocus: true,
                  validator: (val) => roomValidator(val, null),
                  decoration: new InputDecoration(
                    labelText: 'Home',
                  ),
                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
            child: const Text('CANCEL'),
            onPressed: () {
              var form = roomReNameFormKey.currentState;
              form!.reset();
              Navigator.pop(context);
            },
          ),
          new FlatButton(
            child: const Text('RENAME'),
            onPressed: () async {
              await getInternetAccessObject();
              if (internetAccess) {
                var form = roomReNameFormKey.currentState;
                if (form!.validate()) {
                  form.save();
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                    _autoValidateHomeReName = false;
                  });
                  _renameRoom(room.userId, room.roomId, _roomName);
                } else {
                  setState(() {
                    _autoValidateHomeReName = true;
                  });
                }
              } else {
                Navigator.pop(context);
                this._showDialog.showDialogCustom(
                    context,
                    "Internet Connection Problem",
                    "Please check your internet connection",
                    fontSize: 17.0,
                    boxHeight: 58.0);
              }
            },
          ),
        ],
      ),
    );
  }

  _deleteHome(Room room) async {
    await getInternetAccessObject();
    if (internetAccess) {
      bool status = await _confirmation.showConfirmDialog(context);
      if (status) {
        setState(() {
          _isLoading = true;
        });
        await _presenter.doDeleteRoom(room.userId, room.roomId);
      }
    } else {
      this._showDialog.showDialogCustom(context, "Internet Connection Problem",
          "Please check your internet connection",
          fontSize: 17.0, boxHeight: 58.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading ? ShowProgress() : createListView(context, roomList),
    );
  }

  Widget createListView(BuildContext context, List<Room> roomList) {
    return new GridView.count(
      crossAxisCount: 2,
      children: roomList.map((value) => roomWidget(context, value)).toList(),
    );
  }

  Widget roomWidget(BuildContext context, Room room) {
    return Container(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) =>
                UserDevicesFromRooms(home: widget.home, room: room)),
          ),
        ),
        splashColor: kHAutoBlue300,
        child: Container(
          padding:
              EdgeInsets.only(left: 10.0, top: 20.0, bottom: 20.0, right: 10.0),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    title: Hero(
                      tag: Object(),
                      child: Text(
                        "${room.roomName}",
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .headline1!
                            .copyWith(fontSize: 17.0),
                      ),
                    ),
                    subtitle: Text(
                      "${room.roomName}",
                      style: TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                    trailing: new Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 40.0,
                        child: FlatButton(
                          onPressed: () async {
                            await _showRoomReNameDialog(room);
                          },
                          child: Icon(Icons.edit),
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      SizedBox(
                        width: 40.0,
                        child: FlatButton(
                          onPressed: () async {
                            await _deleteHome(room);
                          },
                          child: Icon(Icons.delete),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onError(String errorTxt) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Error", errorTxt);
  }

  @override
  void onSuccess(ResponseDataAPI room) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Success", room.message!);
  }

  @override
  void onSuccessDelete(ResponseDataAPI room) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Success", room.message!);
  }

  @override
  void onSuccessRename(ResponseDataAPI room) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Success", room.message!);
  }

  @override
  void onGetRoomError(String errorTxt) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Error", errorTxt);
  }

  @override
  void onGetRoomSuccess(RoomData room) {
    setState(() {
      roomList = room.room!;
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Success", room.message!);
  }
}
