import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/user_data.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_progress.dart';
import '/models/my_referrals_data.dart';
import '/validators/all_validators.dart';

class AddReferral extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  const AddReferral({Key? key, this.user, this.callbackUser}) : super(key: key);

  @override
  State<AddReferral> createState() => _AddReferralState();
}

class _AddReferralState extends State<AddReferral>
    implements ReferralProgramContractor {
  bool _isLoading = false;
  bool _autoValidateComplain = false;
  bool internetAccess = false;
  bool _isLoadingValue = false;
  bool _obscureTextPass = false;
  bool _obscureTextNewPass = false;
  bool _obscureTextNewConPass = true;
  bool _isError = false;
  late String mobile_no;
  late String _referralName, _referralMobile;
  late ReferralProgramPresetner _presenter;
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  late ShowDialog _showDialog;
  late String _showError;
  var addReferralFormKey = GlobalKey<FormState>();
  List<Referrals> _referrals = <Referrals>[];
  FocusNode _nameFocus = new FocusNode();
  FocusNode _mobileFocus = new FocusNode();

  @override
  void initState() {
    _presenter = new ReferralProgramPresetner(this);
    _showDialog = new ShowDialog();
    getInternetAccessObject();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _addReferral(String referral_name, String referral_mobile) async {
    await _presenter.doAddReferral(
        widget.user!.userId!, referral_name, referral_mobile);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Referral Program"),
        centerTitle: true,
        actions: [],
      ),
      body: _showBody(context),
    );
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
              key: addReferralFormKey,
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
                        Icons.person,
                      ),
                      hintText: "Referral Name",
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    onSaved: (value) {
                      _referralName = value!;
                    },
                    obscureText: _obscureTextPass,
                    validator: nameValidator,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    focusNode: _nameFocus,
                    onFieldSubmitted: (value) {},
                  ),
                  SizedBox(
                    height: 21.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
                      ),
                      hintText: "Referrral Mobile",
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    onSaved: (value) {
                      _referralMobile = value!;
                    },
                    validator: contactValidator,
                    keyboardType: TextInputType.text,
                    obscureText: _obscureTextNewPass,
                    textInputAction: TextInputAction.next,
                    focusNode: _mobileFocus,
                    onFieldSubmitted: (value) {},
                  ),
                  SizedBox(
                    height: 21.0,
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
                  _isLoading
                      ? ShowProgress()
                      : RaisedButton(
                          color: kHAutoBlue300,
                          onPressed: () async {
                            await getInternetAccessObject();
                            if (internetAccess) {
                              var form = addReferralFormKey.currentState;
                              if (form!.validate()) {
                                form.save();
                                setState(() {
                                  _isLoading = true;
                                  _autoValidateComplain = false;
                                });
                                _addReferral(_referralName, _referralMobile);
                              } else {
                                setState(() {
                                  _autoValidateComplain = true;
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Add Referral',
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
  void onAddReferralError(String? error) {
    setState(() {
      _isLoading = false;
      _isLoadingValue = false;
      _isError = true;
      _showError = error!;
    });
    _showDialog.showDialogCustom(context, "Error", error!);
  }

  @override
  void onAddReferralSucccss(String? message) {
    setState(() {
      _isLoading = false;
      _isLoadingValue = false;
      _isError = false;
    });
    _showDialog.showDialogCustom(context, "Success", message!);
  }

  @override
  void onGetReferralError(String? error) {}

  @override
  void onGetReferralSucccss(List<Referrals>? referrals) {}
}
