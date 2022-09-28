import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '/models/user_data.dart';
import '/utils/show_progress.dart';
import '/utils/internet_access.dart';
import '/utils/show_dialog.dart';
import 'package:flutter/services.dart';
import '/utils/show_internet_status.dart';
import '/utils/check_platform.dart';
import 'package:flutter/cupertino.dart';
import '/validators/all_validators.dart';

class ChangePassword extends StatefulWidget {
  User? user;
  Function? callbackUser;
  ChangePassword({this.user, this.callbackUser});
  @override
  ChangePasswordState createState() {
    return ChangePasswordState();
  }
}

class ChangePasswordState extends State<ChangePassword>
    implements UserUpdateContract, UserContract {
  bool _isLoading = true;
  bool _isLoadingValue = false;
  bool internetAccess = false;
  // bool _obscureText = true;
  bool _obscureTextPass = true;
  bool _obscureTextNewPass = true;
  bool _obscureTextNewConPass = true;

  late CheckPlatform _checkPlatform;

  late ShowDialog showDialog;
  late ShowInternetStatus _showInternetStatus;
  bool _isError = false;
  late String _showError;
  late String _oldPassword, _newPassword, _newCPassword;
  FocusNode _oldPasswordFocus = new FocusNode();
  FocusNode _newPasswordFocus = new FocusNode();
  FocusNode _newCPasswordFocus = new FocusNode();
  late UserUpdatePresenter _userUpdatePresenter;
  late UserPresenter _userPresenter;

  var scaffoldKey = new GlobalKey<ScaffoldState>();
  var formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showInternetStatus = new ShowInternetStatus();
    _userUpdatePresenter = new UserUpdatePresenter(this);
    _userPresenter = new UserPresenter(this);
    _checkPlatform = new CheckPlatform(context: context);
    showDialog = new ShowDialog();
    getInternetAccessObject();
    getUserProfile();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUserProfile() async {
    await _userPresenter.doGetUser(widget.user!.userId!);
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  _changePassword() async {
    await getInternetAccessObject();
    if (internetAccess) {
      var form = formKey.currentState;
      if (form!.validate()) {
        form.save();
        if (_newPassword == _newCPassword) {
          this._isError = false;
          setState(() {
            _isLoadingValue = true;
          });
          await _userUpdatePresenter.doChangePassword(
              widget.user!.userId!, _oldPassword, _newPassword);
          form.reset();
        } else {
          this._isError = true;
          this._showError = "New passwords do not match";
        }
      } else {
        _autoValidate = true;
      }
    } else {
      this.showDialog.showDialogCustom(context, "Internet Connection Problem",
          "Please check your internet connection",
          fontSize: 17.0, boxHeight: 58.0);
    }
  }

  Widget _showBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Card(
        elevation: 10.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: kHAutoBlue300!, width: 2.0),
          ),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_open,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _obscureTextPass
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () => setState(() {
                          _obscureTextPass = !_obscureTextPass;
                        }),
                      ),
                      hintText: "Old Password",
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    onSaved: (value) {
                      _oldPassword = value!;
                    },
                    obscureText: _obscureTextPass,
                    validator: oldPasswordValidator,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    focusNode: _oldPasswordFocus,
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                          context, _oldPasswordFocus, _newPasswordFocus);
                    },
                  ),
                  SizedBox(
                    height: 21.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_open,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _obscureTextNewPass
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () => setState(() {
                          _obscureTextNewPass = !_obscureTextNewPass;
                        }),
                      ),
                      hintText: "New Password",
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    onSaved: (value) {
                      _newPassword = value!;
                    },
                    validator: passwordNewValidator,
                    keyboardType: TextInputType.text,
                    obscureText: _obscureTextNewPass,
                    textInputAction: TextInputAction.next,
                    focusNode: _newPasswordFocus,
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                          context, _newPasswordFocus, _newCPasswordFocus);
                    },
                  ),
                  SizedBox(
                    height: 21.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_open,
                      ),
                      suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _obscureTextNewConPass
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () => setState(() {
                                _obscureTextNewConPass =
                                    !_obscureTextNewConPass;
                              })),
                      hintText: "Confirm New Password",
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    onSaved: (value) {
                      _newCPassword = value!;
                    },
                    validator: newPasswordValidator,
                    obscureText: _obscureTextNewConPass,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    focusNode: _newCPasswordFocus,
                    onFieldSubmitted: (value) async {
                      await _changePassword();
                    },
                  ),
                  _isError
                      ? Container(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                child: Text(
                                  "$_showError",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 21.0,
                  ),
                  _isLoadingValue
                      ? ShowProgress()
                      : RaisedButton(
                          color: kHAutoBlue300,
                          onPressed: () async {
                            await _changePassword();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text("Change Password"),
      ),
      body: internetAccess
          ? _isLoading
              ? ShowProgress()
              : RefreshIndicator(
                  child: _showBody(context),
                  onRefresh: () => getUserProfile(),
                )
          : RefreshIndicator(
              child: _showInternetStatus
                  .showInternetStatus(_checkPlatform.isIOS()),
              onRefresh: getInternetAccessObject,
            ),
    );
  }

  @override
  void onUserUpdateError(String errorString) {}

  @override
  void onUserUpdateSuccess(User userDetails) {}

  @override
  void onUserError(String? error) {
    setState(() {
      _isLoading = false;
    });
    this.showDialog.showDialogCustom(context, "Error", "Profile not found");
  }

  @override
  void onUserSuccess(User userDetails) {
    setState(() {
      widget.user = userDetails;
      _isLoading = false;
    });
    this.showDialog.showDialogCustom(context, "Success", "Profile Found");
  }

  @override
  void onPasswordUpdateError(String errorString) {
    setState(() {
      _isLoadingValue = false;
    });
    this.showDialog.showDialogCustom(context, "Error", errorString);
  }

  @override
  void onPasswordUpdateSuccess(String message) {
    setState(() {
      _isLoadingValue = false;
    });
    this.showDialog.showDialogCustom(context, "Success", "Password Changed");
  }
}
