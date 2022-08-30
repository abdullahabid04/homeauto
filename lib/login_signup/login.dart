import 'package:flutter/material.dart';
import '/auth.dart';
import '/models/user_data.dart';
import '/login_signup/login_screen_presenter.dart';
import 'dart:ui';
import '/colors.dart';
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
  User user;
  bool _obscureText = true;
  bool _isLoadingValue = false;
  bool _isLoading = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _password, _contact;
  bool _autoValidate = false;
  LoginScreenPresenter _presenter;
  ShowDialog _showDialog;
  FocusNode _contactNode = new FocusNode();
  FocusNode _passwordNode = new FocusNode();
  LoginScreenState() {
    _presenter = new LoginScreenPresenter(this);
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
    authStateProvider.initState();
  }
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _showDialog = new ShowDialog();
    super.initState();
  }

  Function callbackUser(User userDetails) {
    setState(() {
      this.user = userDetails;
    });
  }

  void _submit() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    if (await checkInternetAccess.check()) {
      final form = formKey.currentState;
      if (form.validate()) {
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

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  onAuthStateChanged(AuthState state, User user) {
    if (state == AuthState.LOGGED_IN) {
      this.callbackUser(user);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    user: this.user,
                    callbackUser: this.callbackUser,
                  )));
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  @override
  Widget build(BuildContext context) {
    String contactValidator(String value) {
      Pattern pattern = r'^[0-9]{10}$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty)
        return 'Contact should not be empty';
      else if (!regex.hasMatch(value))
        return 'Contact should only 10 contain numbers';
      else
        return null;
    }

    String validatePassword(String value) {
      if (value.isEmpty)
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
                  autofocus: true,
                  onSaved: (val) => _contact = val,
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
                        onSaved: (val) => _password = val,
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
    setState(() => _isLoadingValue = false);
    final form = formKey.currentState;
    form.reset();
    var authStateProvider = new AuthStateProvider();
    authStateProvider.notify(AuthState.LOGGED_IN, user);
  }
}
