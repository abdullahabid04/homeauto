import 'package:flutter/material.dart';
import 'package:last_home_auto/screens/controldevice/device_remote.dart';
import 'package:last_home_auto/utils/api_response.dart';
import '../../constants/colors.dart';
import '../../models/device_data.dart';
import '../../models/home_data.dart';
import '../../models/room_data.dart';
import '../../models/specific_device_data.dart';
import '../../models/specific_device_info.dart';
import '../../userpreferances/user_preferances.dart';
import '../../utils/check_platform.dart';
import '../../utils/show_progress.dart';
import '../../constants/colors.dart';
import 'package:flutter/services.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_internet_status.dart';
import '/models/device_data.dart';
import '/models/device_info.dart';
import '/utils/delete_confirmation.dart';
import '/validators/all_validators.dart';

class UserDevicesFromRooms extends StatefulWidget {
  final Home? home;
  final Room? room;
  final String? home_id;
  final String? room_id;
  const UserDevicesFromRooms({
    Key? key,
    this.home,
    this.room,
    this.home_id,
    this.room_id,
  }) : super(key: key);

  @override
  State<UserDevicesFromRooms> createState() => _UserDevicesFromRoomsState();
}

class _UserDevicesFromRoomsState extends State<UserDevicesFromRooms>
    implements
        DeviceUpdateContract,
        DeviceInfoContract,
        SpecificDeviceInfoContract,
        SpecificDeviceContract {
  bool _isLoading = true;
  bool _isChangingState = false;
  Map<String, bool> _changeState = new Map<String, bool>();
  bool internetAccess = false;
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";
  late ShowDialog _showDialog;
  late ShowInternetStatus _showInternetStatus;
  late CheckPlatform _checkPlatform;

  late String _deviceName, _sharedToContact;

  List<SpcificDevices> deviceList = <SpcificDevices>[];
  List<SpecificInfo> infoList = <SpecificInfo>[];
  bool _autoValidateHomeName = false;
  bool _autoValidateHomeReName = false;

  late DeviceUpdatePresenter _presenter;
  late DeviceInfoPresenter _infoPresenter;
  late SpecificDevicePresenter _devicePresenter;
  late SpecificDeviceInfoPresenter _deviceInfoPresenter;
  late DeleteConfirmation _confirmation;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var deviceRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  var deviceNameFormKey = new GlobalKey<FormState>();
  var deviceReNameFormKey = new GlobalKey<FormState>();
  var deviceShareFormKey = new GlobalKey<FormState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _checkPlatform = new CheckPlatform(context: context);
    _confirmation = new DeleteConfirmation();
    _presenter = new DeviceUpdatePresenter(this);
    _infoPresenter = new DeviceInfoPresenter(this);
    _devicePresenter = new SpecificDevicePresenter(this);
    _deviceInfoPresenter = new SpecificDeviceInfoPresenter(this);
    _showDialog = new ShowDialog();
    _showInternetStatus = new ShowInternetStatus();
    checkInternet();
    _getDevicesAndInfo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkInternet() async {
    await getInternetAccessObject();
  }

  _getDevicesAndInfo() async {
    if (widget.home != null && widget.room != null) {
      await _devicePresenter.doGetDevices(
          user_id, widget.home!.homeId!, widget.room!.roomId!);
    } else {
      await _devicePresenter.doGetDevices(
          user_id, widget.home_id!, widget.room_id!);
    }
  }

  _getDevicesInfo() async {
    if (widget.home != null && widget.room != null) {
      await _deviceInfoPresenter.doGetDevicesInfo(
          user_id, widget.home!.homeId!, widget.room!.roomId!);
    } else {
      await _deviceInfoPresenter.doGetDevicesInfo(
          user_id, widget.home_id!, widget.room_id!);
    }
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
  }

  _renameDevice(String? user_id, String? device_id, String device_name) async {
    await _presenter.doUpdateDevice(user_id!, device_id!, device_name);
  }

  _shareDevice(
      String? user_id,
      String shared_to_contact,
      String? home_id,
      String? room_id,
      String? device_id,
      String? device_name,
      String? device_type) async {
    await _infoPresenter.doShareDevice(user_id!, shared_to_contact, home_id!,
        room_id!, device_id!, device_name!, device_type!);
  }

  _powerDevice(String? user_id, String? device_id, String device_status) async {
    await _infoPresenter.doPowerDevice(user_id!, device_id!, device_status);
  }

  _showHomeReNameDialog(SpcificDevices device) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: deviceReNameFormKey,
                child: new TextFormField(
                  initialValue: device.deviceName,
                  onSaved: (val) => _deviceName = val!,
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
                        _renameDevice(
                            device.userId, device.deviceId, _deviceName);
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
              ),
            )
          ],
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
            child: const Text('RENAME'),
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
                  _renameDevice(device.userId, device.deviceId, _deviceName);
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

  _deleteDevice(SpcificDevices device) async {
    await getInternetAccessObject();
    if (internetAccess) {
      bool status = await _confirmation.showConfirmDialog(context);
      if (status) {
        setState(() {
          _isLoading = true;
        });
        await _presenter.doDeleteDevice(device.userId, device.deviceId);
      }
    } else {
      this._showDialog.showDialogCustom(context, "Internet Connection Problem",
          "Please check your internet connection",
          fontSize: 17.0, boxHeight: 58.0);
    }
  }

  _showDeviceNameDialog(SpcificDevices _dv, SpecificInfo _in) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        scrollable: true,
        content: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text("Device Name   : ${_dv.deviceName}"),
              Text("Device Type   : ${_dv.deviceType}"),
              Text("Created at    : ${_dv.dateCreated}"),
              Text("User Role     : ${_in.userRole}"),
              Text("Shared        : ${_in.shared == "1" ? "Yes" : "No"}"),
              Text("Device Status : ${_in.active == "1" ? "On" : "Off"}"),
            ],
          ),
        ),
        actions: <Widget>[
          new TextButton(
              child: const Text('Back'),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  _showDeviceShareDialog(SpcificDevices dv) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: deviceShareFormKey,
                child: new TextFormField(
                  onSaved: (val) => _sharedToContact = val!,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) async {
                    await getInternetAccessObject();
                    if (internetAccess) {
                      var form = deviceShareFormKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        Navigator.pop(context);
                        setState(() {
                          _isLoading = true;
                          _autoValidateHomeName = false;
                        });
                        _shareDevice(
                            dv.userId,
                            _sharedToContact,
                            dv.homeId,
                            dv.roomId,
                            dv.deviceId,
                            dv.deviceName,
                            dv.deviceType);
                      } else {
                        setState(() {
                          _autoValidateHomeName = true;
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
                  validator: (val) => contactValidator(val),
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
                Navigator.pop(context);
              }),
          new FlatButton(
            child: const Text('Share'),
            onPressed: () async {
              await getInternetAccessObject();
              if (internetAccess) {
                var form = deviceShareFormKey.currentState;
                if (form!.validate()) {
                  form.save();
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                    _autoValidateHomeName = false;
                  });
                  _shareDevice(dv.userId, _sharedToContact, dv.homeId,
                      dv.roomId, dv.deviceId, dv.deviceName, dv.deviceType);
                } else {
                  setState(() {
                    _autoValidateHomeName = true;
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return _isLoading
    //     ? ShowProgress()
    //     : internetAccess
    //         ? RefreshIndicator(
    //             key: deviceRefreshIndicatorKey,
    //             child: createListView(context, widget.deviceList, infoList),
    //             onRefresh: () => getDeviceInfoList(),
    //           )
    //         : RefreshIndicator(
    //             key: deviceRefreshIndicatorKey,
    //             child: _showInternetStatus
    //                 .showInternetStatus(_checkPlatform.isIOS()),
    //             onRefresh: () => checkInternet());
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? ShowProgress()
          : createListView(context, deviceList, infoList),
    );
  }

  Widget createListView(BuildContext context, List<SpcificDevices> dvList,
      List<SpecificInfo> inList) {
    return new GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: dvList.length,
      itemBuilder: ((context, index) =>
          createItem(context, dvList, inList, index)),
    );
  }

  Widget createItem(BuildContext contex, deviceList, inList, index) {
    return deviceWidget(context, deviceList[index], inList[index]);
  }

  Widget deviceWidget(
      BuildContext context, SpcificDevices device, SpecificInfo info) {
    return Container(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => DeviceRemote(
                  device_id: device.deviceId!,
                )),
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
                  child: Row(
                    children: <Widget>[
                      _changeState[device.deviceId!] == true
                          ? Container(
                              padding: EdgeInsets.only(right: 0.0, left: 35.0),
                              child: SizedBox(
                                width: 10.0,
                                height: 10.0,
                                child: CircularProgressIndicator(
                                  color: info.active == "1"
                                      ? Colors.green
                                      : Colors.red,
                                  strokeWidth: 2.0,
                                ),
                              ),
                            )
                          : Expanded(
                              child: Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: info.active == "1"
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                      SizedBox(
                        width: _changeState[device.deviceId!] == true
                            ? 40.0
                            : 20.0,
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Switch(
                            focusColor: Colors.white,
                            hoverColor: Colors.black,
                            activeColor: Colors.green,
                            activeTrackColor: Colors.blue,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.yellow,
                            value: info.active == "1" ? true : false,
                            onChanged: (bool value) {
                              setState(() {
                                _changeState[device.deviceId!] = true;
                                info.active = value == true ? "1" : "0";
                              });
                              _powerDevice(device.userId!, device.deviceId!,
                                  value == true ? "on" : "off");
                            },
                            autofocus: true,
                            splashRadius: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                  child: Divider(
                    color: Colors.blueAccent,
                    thickness: 1.0,
                    indent: 5.0,
                    endIndent: 5.0,
                    height: 1.0,
                  ),
                ),
                Expanded(
                  child: Row(children: [
                    Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                                left: 10.0, right: 10.0, top: 1.0, bottom: 1.0),
                            child: Column(
                              children: [
                                Hero(
                                  tag: Object(),
                                  child: Text(
                                    "${device.deviceName}",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .copyWith(fontSize: 15.0),
                                  ),
                                ),
                                Text(
                                  "${device.deviceType}",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                              ],
                            ))),
                  ]),
                ),
                SizedBox(
                  height: 10.0,
                  child: Divider(
                    color: Colors.blueAccent,
                    thickness: 1.0,
                    indent: 5.0,
                    endIndent: 5.0,
                    height: 1.0,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          child: TextButton(
                            onPressed: () async {
                              _showDeviceNameDialog(device, info);
                            },
                            child: Icon(Icons.info),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: TextButton(
                            onPressed: () async {
                              await _showHomeReNameDialog(device);
                            },
                            child: Icon(Icons.edit),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: TextButton(
                            onPressed: () async {
                              await _deleteDevice(device);
                            },
                            child: Icon(Icons.delete),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: TextButton(
                            onPressed: () async {
                              _showDeviceShareDialog(device);
                            },
                            child: Icon(Icons.share),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
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
  void onDeviceDeleteError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);

    setState(() => _isLoading = false);
  }

  @override
  void onDeviceDeleteSuccess(ResponseDataAPI response) {
    _showDialog.showDialogCustom(context, "Error", response.message!);
    setState(() => _isLoading = false);
  }

  @override
  void onDeviceUpdateError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);
    setState(() => _isLoading = false);
  }

  @override
  void onDeviceUpdateSuccess(ResponseDataAPI response) {
    _showDialog.showDialogCustom(context, "Error", response.message!);
    setState(() => _isLoading = false);
  }

  @override
  void onDeviceInfoError() {
    setState(() => _isLoading = false);
  }

  @override
  void onDeviceInfoSuccess(DeviceInfo deviceInfo) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onShareDeviceError() {
    _showDialog.showDialogCustom(context, "Error", "Device not shared");
    setState(() => _isLoading = false);
  }

  @override
  void onShareDeviceSuccess(String? message) {
    _showDialog.showDialogCustom(context, "Success", message!);
    setState(() => _isLoading = false);
  }

  @override
  void onPowerDeviceError(String? message) {
    _showDialog.showDialogCustom(context, "Error", "Device state not changed");
    setState(() => _changeState[message!] = false);
  }

  @override
  void onPowerDeviceSuccess(String? message) {
    _showDialog.showDialogCustom(context, "Success", "Device state changed");
    setState(() => _changeState[message!] = false);
  }

  @override
  void onSpecificDeviceError() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSpecificDeviceInfoError() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSpecificDeviceInfoSuccess(SpecificDeviceInfo deviceInfo) {
    setState(() {
      infoList = deviceInfo.info!;
      _isLoading = false;
    });
  }

  @override
  void onSpecificDeviceSuccess(SpecificDeviceData userDetails) {
    setState(() {
      deviceList = userDetails.devices!;
    });
    _getDevicesInfo();
  }
}
