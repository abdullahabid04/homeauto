import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MyRooms extends StatefulWidget {
  const MyRooms({Key? key}) : super(key: key);

  @override
  State<MyRooms> createState() => _MyRoomsState();
}

class _MyRoomsState extends State<MyRooms>
    implements GetRoomContract, HomeNameContractor, RoomScreenContract {
  bool _isLoading = true;
  bool internetAccess = false;
  bool _autoValidateHomeReName = false;
  late CheckPlatform _checkPlatform;
  late ShowInternetStatus _showInternetStatus;
  late GetRoomPresenter _presenter;
  late HomeNamePresenter _homeNamePresenter;
  late RoomScreenPresenter _roomScreenPresenter;
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
    _homeNamePresenter = new HomeNamePresenter(this);
    _roomScreenPresenter = new RoomScreenPresenter(this);
    checkInternet();
    getHomeNamesList();
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

  getHomeNamesList() async {
    await _homeNamePresenter.doGetNames(user_id);
  }

  createNewRoom(String user_id, String home_name, String room_name) async {
    await _roomScreenPresenter.doCreateRoom(user_id, home_name, room_name);
  }

  deviceValidator(String? val, String? ignoreName) {
    RegExp homeNamePattern = new RegExp(r"^(([A-Za-z]+)([1-9]*))$");
    if (val!.isEmpty) {
      return 'Please enter home name.';
    } else if (!homeNamePattern.hasMatch(val) ||
        val.length < 3 ||
        val.length > 8) {
      return "Home Name invalid.";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("my rooms"),
        actions: [
          _createDropDown(),
          IconButton(
              onPressed: () => _showCreateRoomDialog(), icon: Icon(Icons.add))
        ],
      ),
      body: _isLoading
          ? ShowProgress()
          : internetAccess
              ? RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: rooms.length != 0
                      ? UserRooms(
                          roomList: rooms,
                        )
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

  Widget _createDropDown() {
    return DropdownButton<String>(
      value: dropDownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        setState(() {
          rooms.clear();
          dropDownValue = value!;
          _isLoading = true;
        });
        getroomList(dropDownValue);
      },
      items: homeNames.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  _showCreateRoomDialog() async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(16.0),
              content: Container(
                height: 175,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: deviceReNameFormKey,
                        child: Column(children: [
                          DropdownButton<String>(
                            value: dropDownCreateValue,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? value) {
                              setState(() {
                                dropDownCreateValue = value!;
                              });
                            },
                            items: homeNames
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          new TextFormField(
                            initialValue: "",
                            onSaved: (val) => _roomName = val!,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (val) async {
                              await getInternetAccessObject();
                              if (internetAccess) {
                                var form = deviceReNameFormKey.currentState;
                                if (form!.validate()) {
                                  form.save();
                                  Navigator.pop(context);
                                  setState(() {
                                    _isLoading = true;
                                    _autoValidateHomeReName = false;
                                  });
                                  createNewRoom(
                                      user_id, dropDownCreateValue, _roomName);
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
                            validator: (val) => deviceValidator(val, null),
                            decoration: new InputDecoration(
                              labelText: 'Home',
                            ),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    var form = deviceReNameFormKey.currentState;
                    form!.reset();
                    Navigator.pop(context);
                  },
                ),
                new FlatButton(
                  child: const Text('CREATE'),
                  onPressed: () async {
                    await getInternetAccessObject();
                    if (internetAccess) {
                      var form = deviceReNameFormKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        Navigator.pop(context);
                        setState(() {
                          _isLoading = true;
                          _autoValidateHomeReName = false;
                        });
                        createNewRoom(user_id, dropDownCreateValue, _roomName);
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
            );
          }));
        });
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

  @override
  void onGetNamesError(String error) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onGetNamesSuccess(List<Names> list) {
    setState(() {
      list.forEach((element) {
        homeNames.add(element.homeName!);
      });
      dropDownValue = homeNames[0];
      dropDownCreateValue = homeNames[0];
    });
    getroomList(dropDownValue);
  }

  @override
  void onError(String errorTxt) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSuccess(ResponseDataAPI room) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSuccessDelete(ResponseDataAPI room) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSuccessRename(ResponseDataAPI room) {
    setState(() {
      _isLoading = false;
    });
  }
}
