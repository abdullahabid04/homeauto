import 'package:flutter/material.dart';
import '../userpreferances/user_preferances.dart';
import '/auth.dart';
import '/models/user_data.dart';
import '/login_signup/login_screen_presenter.dart';
import 'dart:ui';
import '../constants/colors.dart';
import '/utils/internet_access.dart';
import '/utils/show_progress.dart';
import '/home.dart';
import '/utils/show_dialog.dart';
import '/login_signup/signup.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen>
    implements LoginScreenContract, AuthStateListener {
  late User user;
  bool _obscureText = true;
  bool _isLoadingValue = false;
  bool _isLoading = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  late String _password, _contact;
  bool _autoValidate = false;
  late LoginScreenPresenter _presenter;
  late ShowDialog _showDialog;
  TextEditingController _contactController = TextEditingController();
  late TextEditingValue _contactValue;
  late TextEditingController _passwordController = new TextEditingController();
  late TextEditingValue _passwordValue;
  FocusNode _contactNode = new FocusNode();
  FocusNode _passwordNode = new FocusNode();
  late String user_contact;
  late String user_password;

  LoginScreenState() {
    _presenter = new LoginScreenPresenter(this);
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showDialog = new ShowDialog();
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
    authStateProvider.initState();
    bool? _isFirstRun = UserSharedPreferences.getFirstRun();
    print(_isFirstRun);
    super.initState();
  }

  callbackUser(User userDetails) {
    setState(() {
      this.user = userDetails;
    });
  }

  void _submit() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    if (await checkInternetAccess.check()) {
      final form = formKey.currentState;
      if (form!.validate()) {
        setState(() => _isLoadingValue = true);
        form.save();
        await _presenter.doLogin(_contact, _password);
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    } else {
      _showSnackBar("Please check internet connection");
    }
  }

  void setFieldsValue(String user_mobile_no, String user_account_password) {
    _contactValue = TextEditingValue(text: user_mobile_no);
    _passwordValue = TextEditingValue(text: user_account_password);
    _contactController.value = _contactValue;
    _passwordController.value = _passwordValue;
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState!
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  @override
  Widget build(BuildContext context) {
    String? contactValidator(String? value) {
      Pattern pattern = r'^[0-9]{10}$';
      RegExp regex = new RegExp(pattern.toString());
      if (value!.isEmpty)
        return 'Contact should not be empty';
      else if (!regex.hasMatch(value))
        return 'Contact should only 10 contain numbers';
      else
        return null;
    }

    String? validatePassword(String? value) {
      if (value!.isEmpty)
        return 'Please enter password';
      else
        return null;
    }

    void _toggle() {
      setState(() {
        _obscureText = !_obscureText;
      });
    }

    var loginBtn = new Container(
      child: new RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: kHAutoBlue300,
        onPressed: _submit,
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: new Text("LOGIN"),
        ),
      ),
    );
    var loginForm = new ListView(
      children: <Widget>[
//        new Center(
//          child: Text(
//            "Home Automation",
//            textScaleFactor: 2.0,
//          ),
//        ),
        Container(
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/logo.png",
                height: 200.0,
              ),
              Container(
                child: Text(
                  "Home Automation",
                  style: TextStyle(
                    fontSize: 25.0,
                    fontFamily: "Raleway",
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 41.0,
        ),
        new Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: new TextFormField(
                  controller: _contactController,
                  autofocus: true,
                  onSaved: (val) => _contact = val!,
                  validator: contactValidator,
                  focusNode: _contactNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _contactNode, _passwordNode);
                  },
                  decoration: new InputDecoration(
                    hintText: "Mobile No",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: new TextFormField(
                        controller: _passwordController,
                        onSaved: (val) => _password = val!,
                        validator: validatePassword,
                        focusNode: _passwordNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (val) {
                          _passwordNode.unfocus();
                          _submit();
                        },
                        decoration: new InputDecoration(
                          hintText: "Password",
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_open,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: _toggle,
                          ),
                        ),
                        obscureText: _obscureText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: _isLoadingValue ? new ShowProgress() : loginBtn,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: FlatButton(
            onPressed: () async {
              Map result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignupScreen()));
              if (result != null && result['success']) {
                _showDialog.showDialogCustom(
                    context, result['message'], "You may login now");
                setState(() {
                  user_contact = UserSharedPreferences.getUserMobileNo() ?? "";
                  user_password =
                      UserSharedPreferences.getUserAccountPassword() ?? "";
                });
                setFieldsValue(user_contact, user_password);
                print(user_contact);
                print(user_password);
              }
            },
            child: Text(
              'Register?',
              textScaleFactor: 1,
              style: TextStyle(
                color: kHAutoBlue50,
              ),
            ),
          ),
        )
      ],
    );

    return new WillPopScope(
      onWillPop: () => new Future<bool>.value(false),
      child: new Scaffold(
        appBar: null,
        key: scaffoldKey,
        body: new Center(
          child: Container(
            padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
            child: _isLoading ? ShowProgress() : loginForm,
          ),
        ),
      ),
    );
  }

  @override
  void onLoginError(String errorText) async {
    await _showDialog.showDialogCustom(context, "Error", errorText);
    setState(() {
      _isLoadingValue = false;
    });
  }

  @override
  void onLoginSuccess(User user) async {
    await UserSharedPreferences.setLoggedInStatus(true);
    setState(() => _isLoadingValue = false);
    final form = formKey.currentState;
    form!.reset();
    var authStateProvider = new AuthStateProvider();
    authStateProvider.notify(AuthState.LOGGED_IN, user);
  }

  @override
  onAuthStateChanged(AuthState state, User? user) async {
    if (state == AuthState.LOGGED_IN) {
      this.callbackUser(user!);
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    user: this.user,
                    callbackUser: this.callbackUser,
                  )));
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
