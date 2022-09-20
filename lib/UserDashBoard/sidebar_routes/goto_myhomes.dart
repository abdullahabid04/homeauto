import 'package:flutter/material.dart';
import 'package:last_home_auto/utils/api_response.dart';
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

class MyHomes extends StatefulWidget {
  const MyHomes({Key? key}) : super(key: key);

  @override
  State<MyHomes> createState() => _MyHomesState();
}

class _MyHomesState extends State<MyHomes>
    implements GetHomeContract, HomeScreenContract {
  bool _isLoading = true;
  bool internetAccess = false;
  bool _autoValidateHomeReName = true;
  late CheckPlatform _checkPlatform;
  late ShowInternetStatus _showInternetStatus;
  late GetHomePresenter _presenter;
  late HomeScreenPresenter _homeScreenPresenter;
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
    _homeScreenPresenter = new HomeScreenPresenter(this);
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

  checkInternet() async {
    await getInternetAccessObject();
  }

  gethomeList() async {
    await _presenter.doGetHome(user_id);
  }

  _createHome(home_name) async {
    await _homeScreenPresenter.doCreateHome(user_id, home_name);
  }

  _showHomeNameDialog() async {
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
                  initialValue: "",
                  onSaved: (val) => _homeName = val!,
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
                        _createHome(_homeName);
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
                  _createHome(_homeName);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Homse"),
        actions: [
          IconButton(
              onPressed: () => _showHomeNameDialog(), icon: Icon(Icons.add))
        ],
      ),
      body: _isLoading
          ? ShowProgress()
          : internetAccess
              ? RefreshIndicator(
                  key: homeRefreshIndicatorKey,
                  child: homes.length != 0
                      ? UserHomes(
                          homeList: homes,
                        )
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

  @override
  void onGetHomeError(String errorText) {}

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

  @override
  void onError(String errorTxt) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSuccess(ResponseDataAPI home) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onSuccessDelete(ResponseDataAPI home) {}

  @override
  void onSuccessRename(ResponseDataAPI home) {}
}
