import "package:flutter/material.dart";
import '../constants/colors.dart';
import '/utils/show_progress.dart';
import '/login_signup/signup_screen_presenter.dart';
import '/utils/show_dialog.dart';
import '/utils/check_platform.dart';
import 'package:flutter/services.dart';
import '/models/account_verify.dart';
import '/userpreferances/user_preferances.dart';
import '/validators/all_validators.dart';

class SignupScreen extends StatefulWidget {
  @override
  SignupScreenState createState() {
    return new SignupScreenState();
  }
}

class SignupScreenState extends State<SignupScreen>
    implements SignupScreenContract, VerifyAccountContractor {
  bool _isLoading = false, _isLoadingValue = false;
  bool _autoValidate = false;
  late ShowDialog _showDialog;
  late CheckPlatform _checkPlatform;

  var scaffoldKey = new GlobalKey<ScaffoldState>();
  var formKey = new GlobalKey<FormState>();
  late String _name, _email, _password, _address, _city, _contact;
  String _passwordValidText =
      "Password should contain at least one small and large alpha characters";

  FocusNode _nameNode = new FocusNode();
  FocusNode _emailNode = new FocusNode();
  FocusNode _passwordNode = new FocusNode();
  FocusNode _addressNode = new FocusNode();
  FocusNode _cityNode = new FocusNode();
  FocusNode _contactNode = new FocusNode();

  late SignupScreenPresenter _presenter;
  late AccountVerifyPresenter _accountVerifyPresenter;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _presenter = new SignupScreenPresenter(this);
    _accountVerifyPresenter = new AccountVerifyPresenter(this);
    _showDialog = new ShowDialog();
    _checkPlatform = new CheckPlatform(context: context);
    super.initState();
  }

  void _submit() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      setState(() => _isLoadingValue = true);
      form.save();
      await _presenter.doSignup(
          _name, _email, _password, _address, _city, _contact);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
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
    var _showRegisterForm = new ListView(
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        new Container(
          padding:
              EdgeInsets.only(top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
          child: new Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: formKey,
            child: Column(
              children: <Widget>[
                new TextFormField(
                  onSaved: (val) {
                    _name = val!;
                  },
                  autofocus: true,
                  focusNode: _nameNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _nameNode, _emailNode);
                  },
                  validator: nameValidator,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.0,
                ),
                new TextFormField(
                  onSaved: (val) {
                    _email = val!;
                  },
                  focusNode: _emailNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _emailNode, _passwordNode);
                  },
                  validator: emailValidator,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    prefixIcon: Icon(
                      Icons.email,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.0,
                ),
                new TextFormField(
                  onSaved: (val) {
                    _password = val!;
                  },
                  validator: passwordValidator,
                  obscureText: true,
                  focusNode: _passwordNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _passwordNode, _addressNode);
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    prefixIcon: Icon(
                      Icons.lock_open,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    suffixIcon: Tooltip(
                      message: _passwordValidText,
                      padding: EdgeInsets.all(20.0),
                      verticalOffset: 10.0,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () {},
                        child: Container(
                          child: Text("?"),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.0,
                ),
                new TextFormField(
                  onSaved: (val) {
                    _address = val!;
                  },
                  focusNode: _addressNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _addressNode, _cityNode);
                  },
                  validator: addressValidator,
                  decoration: InputDecoration(
                    hintText: 'Address',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    prefixIcon: Icon(
                      Icons.home,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.0,
                ),
                new TextFormField(
                  onSaved: (val) {
                    _city = val!;
                  },
                  focusNode: _cityNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (val) {
                    _fieldFocusChange(context, _cityNode, _contactNode);
                  },
                  validator: cityValidator,
                  decoration: InputDecoration(
                    hintText: 'City',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    prefixIcon: Icon(
                      Icons.location_city,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.0,
                ),
                new TextFormField(
                  onSaved: (val) {
                    _contact = val!;
                  },
                  focusNode: _contactNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (val) {
                    _contactNode.unfocus();
                    _submit();
                  },
                  validator: contactValidator,
                  decoration: InputDecoration(
                    hintText: 'Contact',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    prefixIcon: Icon(
                      Icons.phone,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.0,
                ),
                Container(
                  child: _isLoadingValue
                      ? ShowProgress()
                      : new RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          color: kHAutoBlue300,
                          onPressed: _submit,
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            child: Text(
                              'Signup',
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Container(
                  child: new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Login?',
                      style: TextStyle(color: kHAutoBlue50),
                      textScaleFactor: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: _isLoading ? ShowProgress() : _showRegisterForm,
    );
  }

  @override
  void onSignupSuccess(var res) async {
    await _accountVerifyPresenter.doVerify(res.userId, res.code.toString());
    UserSharedPreferences.setAccountCreatedStatus(true);
    UserSharedPreferences.setUserId(int.parse(res.user.id.toString()));
    UserSharedPreferences.setUserUniqueId(res.user.userId);
    UserSharedPreferences.setUserName(res.user.userName);
    UserSharedPreferences.setUserEmail(res.user.eMail);
    UserSharedPreferences.setUserMobileNo(res.user.mobileNo);
    UserSharedPreferences.setUserAccountPassword(res.user.password);
    UserSharedPreferences.setUserCity(res.user.city);
    UserSharedPreferences.setUserAddress(res.user.address);
    UserSharedPreferences.setUserCreatedDate(res.user.dateCreated);
  }

  @override
  void onSignupError(String errorTxt) {
    print("x");
    _showDialog.showDialogCustom(context, "Error", errorTxt,
        fontSize: 17.0, boxHeight: 58.0);
    setState(() {
      _isLoadingValue = false;
    });
  }

  @override
  void onVerifyAccountSuccess(String? message) {
    UserSharedPreferences.setVerifiedStatus(true);
    Map result = new Map();
    result['success'] = true;
    result['message'] = message;
    setState(() => _isLoadingValue = false);
    Navigator.of(context).pop(result);
  }

  @override
  void onVerifyAccountError(String? error) {
    setState(() => _isLoadingValue = false);
  }
}
