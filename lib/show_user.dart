import 'package:flutter/material.dart';
import '/models/user_data.dart';
import '/login_signup/logout.dart';
import '/utils/show_dialog.dart';
import 'package:flutter/cupertino.dart';
import '/colors.dart';
import 'package:flutter/services.dart';
import '/utils/internet_access.dart';
import '/user_profile.dart';
import '/utils/check_platform.dart';
import '/change_password.dart';
import 'package:share/share.dart';
import '/utils/show_progress.dart';

class ShowUser extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  ShowUser({this.user, this.callbackUser});
  @override
  ShowUserState createState() {
    return ShowUserState(user, callbackUser);
  }
}

class ShowUserState extends State<ShowUser> implements UserUpdateContract {
  bool _isLoading = false;
  bool internetAccess = false;
  late CheckPlatform _checkPlatform;
  late ShowDialog _showDialog;

  late User user;
  late Function callbackUser;
  late String link;

  late UserUpdatePresenter _userUpdatePresenter;
  ShowUserState(user, callbackUser) {
    this.user = user;
    this.callbackUser = callbackUser;
  }
  callbackThis(User user) {
    setState(() {
      this.user = user;
    });
    this.callbackUser(user);
  }

  @override
  initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showDialog = new ShowDialog();
    _checkPlatform = new CheckPlatform(context: context);
    _userUpdatePresenter = new UserUpdatePresenter(this);
    getInternetAccessObject();
    super.initState();
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  Future getAppLink() async {
    await getInternetAccessObject();
    if (internetAccess) {
      setState(() {
        _isLoading = true;
      });
      String link =
          await _userUpdatePresenter.api.getAppLink(_checkPlatform.isIOS());
      setState(() {
        this.link = link;
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      await _showDialog.showDialogCustom(context, "Internet Connection Problem",
          "Please check your internet connection",
          fontSize: 17.0, boxHeight: 58.0);
    }
  }

  @override
  void onUserUpdateSuccess(User user) {}
  @override
  void onUserUpdateError(String errorString) {
    _showDialog.showDialogCustom(context, "Error", errorString);
  }

  Widget _showBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfile(
                      user: this.user, callbackUser: this.callbackThis),
                ),
              );
            },
            title: Text("Edit Profile"),
          ),
          SizedBox(
            height: 5.0,
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePassword(
                      user: this.user, callbackUser: this.callbackThis),
                ),
              );
            },
            title: Text("Change Password"),
          ),
          SizedBox(
            height: 5.0,
          ),
          SizedBox(
            height: 50.0,
          ),
          Container(
            padding: EdgeInsets.zero,
            child: GetLogOut(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Home Automation"),
      ),
      body: _isLoading ? ShowProgress() : _showBody(context),
    );
  }
}
