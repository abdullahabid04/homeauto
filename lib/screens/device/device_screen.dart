import 'package:flutter/material.dart';
import 'package:last_home_auto/utils/api_response.dart';
import '../../colors.dart';
import '../../models/device_data.dart';
import '/colors.dart';
import 'package:flutter/services.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_internet_status.dart';
import '/models/device_data.dart';
import '/utils/delete_confirmation.dart';

class UserDevices extends StatefulWidget {
  final deviceList;
  const UserDevices({Key? key, this.deviceList}) : super(key: key);

  @override
  State<UserDevices> createState() => _UserDevicesState();
}

class _UserDevicesState extends State<UserDevices>
    implements DeviceUpdateContract {
  bool _isLoading = true;
  bool internetAccess = false;
  late ShowDialog _showDialog;
  late ShowInternetStatus _showInternetStatus;

  late String _deviceName;
  var deviceNameFormKey = new GlobalKey<FormState>();
  var deviceReNameFormKey = new GlobalKey<FormState>();
  bool _autoValidateHomeName = false;
  bool _autoValidateHomeReName = false;

  late DeviceUpdatePresenter _presenter;
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
    _showDialog = new ShowDialog();
    _showInternetStatus = new ShowInternetStatus();
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
    return createListView(context, widget.deviceList);
  }

  Widget createListView(BuildContext context, List<Devices> dvList) {
    return new GridView.count(
      crossAxisCount: 2,
      // Generate 100 Widgets that display their index in the List
      children: dvList.map((value) => deviceWidget(context, value)).toList(),
    );
  }

  Widget deviceWidget(BuildContext context, Devices device) {
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
                  child: ListTile(
                    title: Hero(
                      tag: Object(),
                      child: Text(
                        "${device.deviceName}",
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .headline1!
                            .copyWith(fontSize: 17.0),
                      ),
                    ),
                    subtitle: Text(
                      "${device.deviceType}",
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
                            await _showHomeReNameDialog(device);
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
                            await _deleteDevice(device);
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
  void onDeviceDeleteError(String errorString) {
    // TODO: implement onDeviceDeleteError
  }

  @override
  void onDeviceDeleteSuccess(ResponseDataAPI response) {
    // TODO: implement onDeviceDeleteSuccess
  }

  @override
  void onDeviceUpdateError(String errorString) {
    // TODO: implement onDeviceUpdateError
  }

  @override
  void onDeviceUpdateSuccess(ResponseDataAPI response) {
    // TODO: implement onDeviceUpdateSuccess
  }
}
