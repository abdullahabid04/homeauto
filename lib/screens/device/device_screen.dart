import 'package:flutter/material.dart';
import 'package:last_home_auto/utils/api_response.dart';
import '../../colors.dart';
import '../../models/device_data.dart';
import '../../utils/show_progress.dart';
import '/colors.dart';
import 'package:flutter/services.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_internet_status.dart';
import '/models/device_data.dart';
import '/models/device_info.dart';
import '/utils/delete_confirmation.dart';

class UserDevices extends StatefulWidget {
  final deviceList;
  const UserDevices({Key? key, this.deviceList}) : super(key: key);

  @override
  State<UserDevices> createState() => _UserDevicesState();
}

class _UserDevicesState extends State<UserDevices>
    implements DeviceUpdateContract, DeviceInfoContract {
  bool _isLoading = true;
  bool internetAccess = false;
  late ShowDialog _showDialog;
  late ShowInternetStatus _showInternetStatus;

  late String _deviceName;
  late List<Info> infoList = <Info>[];
  var deviceNameFormKey = new GlobalKey<FormState>();
  var deviceReNameFormKey = new GlobalKey<FormState>();
  bool _autoValidateHomeName = false;
  bool _autoValidateHomeReName = false;

  late DeviceUpdatePresenter _presenter;
  late DeviceInfoPresenter _infoPresenter;
  late DeleteConfirmation _confirmation;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var deviceRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _confirmation = new DeleteConfirmation();
    _presenter = new DeviceUpdatePresenter(this);
    _infoPresenter = new DeviceInfoPresenter(this);
    _showDialog = new ShowDialog();
    _showInternetStatus = new ShowInternetStatus();
    getDeviceInfoList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getDeviceInfoList() async {
    await _infoPresenter.doGetDevicesInfo("13-abdullah-1029384756");
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
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

  _renameDevice(String? user_id, String? device_id, String device_name) async {
    await _presenter.doUpdateDevice(user_id!, device_id!, device_name);
  }

  _showHomeReNameDialog(Devices device) async {
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

  _deleteDevice(Devices device) async {
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? ShowProgress()
        : createListView(context, widget.deviceList, infoList);
  }

  Widget createListView(
      BuildContext context, List<Devices> dvList, List<Info> inList) {
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

  Widget deviceWidget(BuildContext context, Devices device, Info info) {
    return Container(
      child: InkWell(
        onTap: () async {},
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
                      Expanded(
                        child: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                info.active == "1" ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: FlatButton(
                            onPressed: () async {},
                            child: Icon(Icons.share),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
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
                                info.active = value == true ? "1" : "0";
                              });
                            },
                            autofocus: true,
                            splashRadius: 15.0,
                          ),
                        ),
                      )
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
                                    textAlign: TextAlign.left,
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
                            onPressed: () async {},
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
                      )
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
  }

  @override
  void onDeviceDeleteSuccess(ResponseDataAPI response) {
    _showDialog.showDialogCustom(context, "Error", response.message!);
  }

  @override
  void onDeviceUpdateError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);
  }

  @override
  void onDeviceUpdateSuccess(ResponseDataAPI response) {
    _showDialog.showDialogCustom(context, "Error", response.message!);
  }

  @override
  void onDeviceInfoError() {
    _showDialog.showDialogCustom(context, "Error", "Device Info not found");
  }

  @override
  void onDeviceInfoSuccess(DeviceInfo deviceInfo) {
    setState(() {
      infoList = deviceInfo.info!;
    });
    Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
    });
  }
}
