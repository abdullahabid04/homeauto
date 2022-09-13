import 'package:flutter/material.dart';
import 'package:last_home_auto/utils/api_response.dart';
import '../../constants/colors.dart';
import '../../models/home_data.dart';
import '../../constants/colors.dart';
import 'package:flutter/services.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_internet_status.dart';
import '/utils/delete_confirmation.dart';

class UserHomes extends StatefulWidget {
  final homeList;
  const UserHomes({Key? key, this.homeList}) : super(key: key);

  @override
  State<UserHomes> createState() => _UserHomesState();
}

class _UserHomesState extends State<UserHomes> implements HomeScreenContract {
  bool _isLoading = true;
  bool internetAccess = false;
  late ShowDialog _showDialog;
  late ShowInternetStatus _showInternetStatus;

  late String _homeName;
  var homeNameFormKey = new GlobalKey<FormState>();
  var homeReNameFormKey = new GlobalKey<FormState>();
  bool _autoValidateHomeName = false;
  bool _autoValidateHomeReName = false;

  late HomeScreenPresenter _presenter;
  late DeleteConfirmation _confirmation;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var deviceRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _confirmation = new DeleteConfirmation();
    _presenter = new HomeScreenPresenter(this);
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

  homeValidator(String? val, String? ignoreName) {
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

  _renameHome(String? user_id, String? home_id, String home_name) async {
    await _presenter.doRenameHome(user_id!, home_id!, home_name);
  }

  _showHomeReNameDialog(Home home) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: homeReNameFormKey,
                child: new TextFormField(
                  initialValue: home.homeName,
                  onSaved: (val) => _homeName = val!,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) async {
                    await getInternetAccessObject();
                    if (internetAccess) {
                      var form = homeReNameFormKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        Navigator.pop(context);
                        setState(() {
                          _isLoading = true;
                          _autoValidateHomeReName = false;
                        });
                        _renameHome(home.userId, home.homeId, _homeName);
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
                  validator: (val) => homeValidator(val, null),
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
              var form = homeReNameFormKey.currentState;
              form!.reset();
              Navigator.pop(context);
            },
          ),
          new FlatButton(
            child: const Text('RENAME'),
            onPressed: () async {
              await getInternetAccessObject();
              if (internetAccess) {
                var form = homeReNameFormKey.currentState;
                if (form!.validate()) {
                  form.save();
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                    _autoValidateHomeReName = false;
                  });
                  _renameHome(home.userId, home.homeId, _homeName);
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

  _deleteHome(Home home) async {
    await getInternetAccessObject();
    if (internetAccess) {
      bool status = await _confirmation.showConfirmDialog(context);
      if (status) {
        setState(() {
          _isLoading = true;
        });
        await _presenter.doDeleteHome(home.userId, home.homeId);
      }
    } else {
      this._showDialog.showDialogCustom(context, "Internet Connection Problem",
          "Please check your internet connection",
          fontSize: 17.0, boxHeight: 58.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return createListView(context, widget.homeList);
  }

  Widget createListView(BuildContext context, List<Home> homeList) {
    return new GridView.count(
      crossAxisCount: 2,
      // Generate 100 Widgets that display their index in the List
      children: homeList.map((value) => homeWidget(context, value)).toList(),
    );
  }

  Widget homeWidget(BuildContext context, Home home) {
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
                        "${home.homeName}",
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .headline1!
                            .copyWith(fontSize: 17.0),
                      ),
                    ),
                    subtitle: Text(
                      "${home.homeName}",
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
                            await _showHomeReNameDialog(home);
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
                            await _deleteHome(home);
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
    // TODO: implement onError
  }

  @override
  void onSuccess(ResponseDataAPI home) {
    // TODO: implement onSuccess
  }

  @override
  void onSuccessDelete(ResponseDataAPI home) {
    // TODO: implement onSuccessDelete
  }

  @override
  void onSuccessRename(ResponseDataAPI home) {
    // TODO: implement onSuccessRename
  }
}
